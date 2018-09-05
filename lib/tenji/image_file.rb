# frozen_string_literal: true

module Tenji
  class ImageFile < Jekyll::StaticFile
    using Tenji::Refinements

    include Tenji::Processable

    attr_accessor :position

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

    def <=>(other)
      this_datetime = data.fetch('exif', nil)&.fetch('date_time', nil)
      other_datetime = other.data.fetch('exif', nil)&.fetch('date_time', nil)

      name_sort = config.sort('name', gallery_name)
      time_sort = config.sort('time', gallery_name)

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

    def downloadable?()
      res = @data['page'].data['downloadable']
      res.nil? ? config.downloadable?(gallery_name) : res
    end
    
    def gallery=(gallery)
      @data['gallery'] = gallery
    end
    
    def image_next()
      return unless position + 1 < images.size
      images[position + 1]
    end

    def image_prev()
      return unless position > 0
      images[position - 1]
    end

    def page=(page)
      @data['page'] = page
    end

    def sizes=(sizes)
      @data['sizes'] = sizes
    end

    def to_liquid()
      @data['downloadable'] = downloadable?
      @data['next'] = image_next
      @data['prev'] = image_prev
      @data['url'] = url
      super
    end

    private def images()
      data['gallery'].data['images']
    end

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
