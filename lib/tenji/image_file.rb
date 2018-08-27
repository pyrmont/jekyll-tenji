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
      @data = Hash.new
      @position = nil

      read_exif base, dir, name

      process_dir
    end

    def <=>(other)
      @name <=> other.name
    end
    
    def gallery=(gallery)
      @data['gallery'] = gallery
    end

    def page=(page)
      @data['page'] = page
    end

    def sizes=(sizes)
      @data['sizes'] = sizes
    end

    private def read_exif(base, dir, name)
      filename = File.join(base, dir, name)
      filename.is_a! String

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
