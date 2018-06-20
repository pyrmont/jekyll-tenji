module Tenji
  module Utilities
    using Tenji::Refinements

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
          data = SafeYAML.load Regexp.last_match(1)
        end
      rescue Psych::SyntaxError => e
        Jekyll.logger.warn "YAML Exception reading #{filename}: #{e.message}"
        raise e if config["strict_front_matter"]
      rescue StandardError => e
        Jekyll.logger.warn "Error reading file #{filename}: #{e.message}"
        raise e if config["strict_front_matter"]
      end

      [ data, content ]
    end
  end
end
