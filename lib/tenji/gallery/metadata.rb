require 'jekyll'

module Tenji
  class Gallery
    class Metadata
      attr_accessor :name, :description, :period, :singles, :paginate

      def initialize(metadata = nil, dir_name)
        metadata ||= Hash.new
        @name = metadata["name"] || dir_name
        @description = metadata["description"] || ''
        @period = Tenji::Gallery::Metadata.parse_period metadata["period"]
        @singles = metadata["singles"] || false
        @paginate = metadata["paginate"] || 25
      end

      def self.parse_period(period_string)
        return Array.new if period_string.nil?
        components = period_string.split '-'
        components.map { |c| Date.parse(c) }
      end
    end
  end
end
