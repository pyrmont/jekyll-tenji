require 'jekyll'

module Tenji
  class Gallery
    class Metadata
      attr_accessor :data

      def initialize(metadata = {}, dir_name)
        @data = metadata || Hash.new
        @data['name'] ||= dir_name
        @data['description'] ||= ''
        @data['period'] = Tenji::Gallery::Metadata.parse_period @data['period']
        @data['singles'] ||= false
        @data['paginate'] ||= 25
        @data['layout'] ||= 'gallery_index'
      end

      def [](k)
        @data[k]
      end

      def self.parse_period(period_string)
        return Array.new if period_string.nil?
        components = period_string.split '-'
        components.map { |c| Date.parse(c) }
      end
    end
  end
end
