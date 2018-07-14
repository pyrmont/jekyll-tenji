# frozen_string_literal: true

module Tenji
  module Utilities
    using Tenji::Refinements

    def self.parse_period(period)
      period.is_a! String

      components = period.split '-'
      components.map { |c| Date.parse(c.strip) }
    end

    def self.read_exif(file)
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

    def self.read_yaml(file, config = {})
      file.is_a! Pathname
      config.is_a! Hash

      return [ Hash.new, '' ] unless file.exist?

      filename = file.realpath.to_s
      begin
        content = ::File.read filename
        if content =~ Jekyll::Document::YAML_FRONT_MATTER_REGEXP
          content = $POSTMATCH
          data = SafeYAML.load(Regexp.last_match(1)) || Hash.new
          data['period'] = parse_period(data['period'] || '')
        end
      rescue Psych::SyntaxError => e
        Jekyll.logger.warn "YAML Exception reading #{filename}: #{e.message}"
        raise e if config["strict_front_matter"]
      rescue StandardError => e
        Jekyll.logger.warn "Error reading #{filename}: #{e.message}"
        raise e if config["strict_front_matter"]
      ensure
        data ||= Hash.new
        content ||= ''
      end

      [ data, content ]
    end
  end
end
