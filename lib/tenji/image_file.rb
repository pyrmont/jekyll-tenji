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
      @data = @site.frontmatter_defaults.all(relative_path, type)
      @position = nil

      read_exif base, dir, name
    end

    def <=>(other)
      @name <=> other.name
    end

    def downloadable?()
      raise StandardError unless @data['page']
      @data['page'].data['downloadable'] || config.downloadable?(gallery_name)
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
