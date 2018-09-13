# frozen_string_literal: true

module Tenji
  
  # An image file located in a gallery
  #
  # {Tenji::ImageFile} represents an image file located within a gallery 
  # directory. This class inherits from the `Jekyll::StaticFile` class and is
  # largely processed by Jekyll like any other static file in the website.
  #
  # One important difference is how the class handles the initialisation
  # parameters. Jekyll assumes that the `dir` parameter represents both
  # the directory name in the source directory and the directory name in the 
  # destination directory name. This is not necessarily the case in Tenji. See 
  # the {#initialize} documentation for more information.
  #
  # Another difference is that EXIF data is read in and made accessible through
  # the `@data['exif']` object. The value for the `exif` keyword is `nil` if no
  # EXIF data is present in this image.
  #
  #
  # @since 0.1.0
  # @api private
  class ImageFile < Jekyll::StaticFile
    using Tenji::Refinements

    include Tenji::Processable

    attr_accessor :position

    # Initialise an object of this class
    #
    # As noted above, while the `dir` parameter represents the path to the
    # source directory, it does not necessarily represent the path to the
    # destination directory. There are two situations in which this occurs.
    #
    # The first is if the user prefixes the directory with an ordinal pattern
    # (eg. `01-`, `02-`) as a means of ordering the galleries. Tenji will use
    # this prefix to order the galleries in internal references but will remove
    # the prefix in the output.
    #
    # The second is is if the user has marked the gallery as `hidden`. In this
    # case, Tenji will generate an obfuscated name and use this in the
    # destination directory path. The obfuscation uses
    # `Base64#urlsafe_encode64` to transform the name.
    #
    # @param site [Jekyll::Site] an object representing the Jekyll site
    # @param base [String] the base path
    # @param dir [String] the directory path
    # @param name [String] the basename of the file
    #
    # @return [Tenji::GalleryPage] the intialised object
    #
    # @since 0.1.0
    # @api private
    def initialize(site, base, dir, name)
      @config = Tenji::Config
      @gallery_name = pathify(dir).name
      
      @site = site
      @base = base
      @dir = dir
      @name = name
      @path = File.join(base, dir, name)

      process_dir config.dir(:galleries),
                  config.dir(:galleries, :out),
                  gallery_name,
                  output_gallery_name
      
      @relative_path = File.join(@dir, @name)
      @extname = File.extname(@name)
      @data = @site.frontmatter_defaults.all(File.join(dir, name), type)
      @position = nil

      read_exif base, dir, name
    end

    # Comparison operator
    #
    # {Tenji::ImageFile} objects are compared on some combination of the capture
    # time and the name of the image. A user can configure whether the capture
    # time is ignored and the direction in which capture times and names are
    # sorted.
    #
    # @param other [Tenji::ImageFile] the object to compare
    #
    # @return [-1, 0, 1]
    #
    # @since 0.1.0
    # @api private
    def <=>(other)
      this_datetime = data.fetch('exif', nil)&.fetch('date_time', nil)
      other_datetime = other.data.fetch('exif', nil)&.fetch('date_time', nil)

      name_sort = config.sort(:name, gallery_name)
      time_sort = config.sort(:time, gallery_name)

      if time_sort == :ignore || this_datetime == other_datetime
        (name <=> other.name) * name_sort
      elsif this_datetime.nil?
        1
      elsif other_datetime.nil?
        -1
      else
        (this_datetime <=> other_datetime) * time_sort 
      end
    end

    # Return whether the image is downloadable
    #
    # @return [Boolean] whether the image is downloadable
    #
    # @since 0.1.0
    # @api private
    def downloadable?()
      res = @data['page'].data['downloadable']
      res.nil? ? config.downloadable?(gallery_name) : res
    end
    
    # Assign an object to the `'gallery'` key in the `@data` hash
    #
    # @param gallery [Tenji::GalleryPage] the gallery page for this image
    #
    # @since 0.1.0
    # @api private
    def gallery=(gallery)
      @data['gallery'] = gallery
    end
    
    # Return the next image in the gallery
    #
    # @return [Tenji::ImageFile, nil] the next image in the gallery or `nil` if
    #   there is no next image
    #
    # @since 0.1.0
    # @api private
    def image_next()
      return unless position + 1 < images.size
      images[position + 1]
    end

    # Return the previous image in the gallery
    #
    # @return [Tenji::ImageFile, nil] the previous image in the gallery or `nil`
    #   if there is no previous image
    #
    # @since 0.1.0
    # @api private
    def image_prev()
      return unless position > 0
      images[position - 1]
    end

    # Assign an object to the `'page'` key in the '@data' hash
    #
    # @param page [Tenji::ImagePage] the single image page for this image
    #
    # @since 0.1.0
    # @api private
    def page=(page)
      @data['page'] = page
    end

    # Assign an object to the '`sizes`' key in the '@data' hash
    #
    # @param sizes [Array<Tenji::ThumbFile>] the thumbnails for this image
    #
    # @since 0.1.0
    # @api private
    def sizes=(sizes)
      @data['sizes'] = sizes
    end

    # Convert this object to a hash for use in Liquid templates
    #
    # @return [Hash] the representation of this object as a hash
    #
    # @since 0.1.0
    # @api private
    def to_liquid()
      @data['downloadable'] = downloadable?
      @data['next'] = image_next
      @data['prev'] = image_prev
      @data['url'] = url
      super
    end

    # Return all the images in the associated gallery
    #
    # @return [Array<Tenji::ImageFile>] the images in the associated gallery
    #
    # @since 0.1.0
    # @api private
    private def images()
      data['gallery'].data['images']
    end

    # Read the EXIF data embedded in this file
    #
    # @param base [String] the base path
    # @param dir [String] the directory
    # @param name [String] the basename of the file
    #
    # @since 0.1.0
    # @api private
    private def read_exif(base, dir, name)
      filename = File.join(base, dir, name)

      file = pathify(filename)

      return unless file.exist?

      begin
        exif_data = EXIFR::JPEG.new(File.open(filename)).to_hash
        southern_hemisphere = exif_data[:gps_latitude_ref] == 'S'
        western_hemisphere = exif_data[:gps_longitude_ref] == 'W'
        exif_data[:gps_latitude][0] *= -1 if southern_hemisphere
        exif_data[:gps_longitude][0] *= -1 if western_hemisphere
        exif_data.transform_keys! &:to_s
        data['exif'] = exif_data
      rescue EXIFR::MalformedJPEG => e
        Jekyll.logger.warn "EXIFR Exception reading #{filename}: #{e.message}"
      rescue StandardError => e
        Jekyll.logger.warn "Error reading #{filename}: #{e.message}"
      end
    end
  end
end
