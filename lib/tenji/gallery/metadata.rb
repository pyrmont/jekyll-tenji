require 'jekyll'

module Tenji
  class Gallery
    class Metadata
      include Jekyll::Convertible

      attr_accessor :name,
                    :description,
                    :period,
                    :singles,
                    :paginate

      def initialize(file)
        metadata = init_metadata file
        @name = metadata["name"] || file.parent.basename.to_s
        @description = metadata["description"] || ''
        @period = init_period metadata["period"]
        @singles = metadata["singles"] || false
        @paginate = metadata["paginate"] || 25
      end

      private

      def init_metadata(file)
        return Hash.new unless file.exist?

        metadata = Hash.new

        begin
          metadata['content'] = File.read file.realpath.to_s
          if metadata['content'] =~ Jekyll::Document::YAML_FRONT_MATTER_REGEXP
            metadata['content'] = $POSTMATCH
            metadata.merge!(SafeYAML.load Regexp.last_match(1))
          end
        rescue Psych::SyntaxError => e
          Jekyll.logger.warn "YAML Exception reading #{file}: #{e.message}"
          # raise e if @site.config["strict_front_matter"]
          raise e
        rescue StandardError => e
          Jekyll.logger.warn "Error reading file #{file}: #{e.message}"
          # raise e if @site.config["strict_front_matter"]
          raise e
        end
        
        metadata
      end

      def init_period(period_string)
        return Array.new if period_string.nil?
        components = period_string.split '-'
        components.map { |c| Date.parse(c) }
      end

    end
  end
end
