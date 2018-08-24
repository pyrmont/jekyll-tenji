# frozen_string_literal: true

module Tenji
  module Utilities
    using Tenji::Refinements

    def parse_period(period)
      period.is_a! String

      components = period.split '-'
      components.map { |c| Date.parse(c.strip) }
    end

    def read_exif(file)
      file.is_a! Pathname

      return Hash.new unless file.exist?

      filename = file.realpath.to_s
      begin
        data = EXIFR::JPEG.new(::File.open(filename)).to_hash
        southern_hemisphere = data[:gps_latitude_ref] == 'S'
        western_hemisphere = data[:gps_longitude_ref] == 'W'
        data[:gps_latitude][0] *= -1 if southern_hemisphere
        data[:gps_longitude][0] *= -1 if western_hemisphere
        data.transform_keys &:to_s
      rescue EXIFR::MalformedJPEG => e
        Jekyll.logger.warn "EXIFR Exception reading #{filename}: #{e.message}"
        Hash.new
      rescue StandardError => e
        Jekyll.logger.warn "Error reading #{filename}: #{e.message}"
        Hash.new
      end
    end
  end
end
