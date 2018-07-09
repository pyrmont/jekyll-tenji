module Tenji
  module Utilities
    using Tenji::Refinements
    
    def self.parse_period(period)
      period.is_a! String

      components = period.split '-'
      components.map { |c| Date.parse(c.strip) }
    end

    def self.read_exif(path)
      begin
        data = EXIFR::JPEG.new(::File.open(path)).to_hash
        if data[:gps_latitude] && data[:gps_longitude]
          data[:gps_latitude][0] *= (data[:gps_latitude_ref] == 'N') ? 1 : -1 
          data[:gps_longitude][0] *= (data[:gps_longitude_ref] == 'E') ? 1 : -1
        end
        data.transform_keys &:to_s
      rescue EXIFR::MalformedJPEG => e
        Jekyll.logger.warn "EXIFR Exception reading #{path}: #{e.message}"
        Hash.new
      end
    end

    def self.read_yaml(file, config = {})
      file.is_a! Pathname
      config.is_a! Hash

      data = Hash.new
      content = ''
      return [ data, content ] unless file.exist?

      filename = file.realpath.to_s
      begin
        content = ::File.read filename
        if content =~ Jekyll::Document::YAML_FRONT_MATTER_REGEXP
          content = $POSTMATCH
          data = SafeYAML.load(Regexp.last_match(1)) || Hash.new
        end
      rescue Psych::SyntaxError => e
        Jekyll.logger.warn "YAML Exception reading #{filename}: #{e.message}"
        raise e if config["strict_front_matter"]
      rescue StandardError => e
        Jekyll.logger.warn "Error reading file #{filename}: #{e.message}"
        raise e if config["strict_front_matter"]
      end

      data['period'] = data['period'] ? parse_period(data['period']) : nil

      [ data, content ]
    end
  end
end
