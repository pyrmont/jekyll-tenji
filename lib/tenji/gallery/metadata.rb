require 'yaml'

module Tenji
  class Gallery
    class Metadata
      attr_accessor :name,
                    :description,
                    :period,
                    :singles,
                    :paginate

      def initialize(file)
        metadata = file.exist? ? YAML.load_file(file.realpath) : {}
        @name = metadata["name"] || file.parent.basename.to_s
        @description = metadata["description"] || ''
        @period = init_period metadata["period"]
        @singles = metadata["singles"] || false
        @paginate = metadata["paginate"] || 25
      end

      private

      def init_period(period_string)
        return Array.new if period_string.nil?
        components = period_string.split '-'
        components.map { |c| Date.parse(c) }
      end

    end
  end
end
