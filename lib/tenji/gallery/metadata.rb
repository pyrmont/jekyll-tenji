require 'jekyll'
require 'tenji/refinements'

module Tenji
  class Gallery
    class Metadata
      using Tenji::Refinements

      attr_reader :data

      def initialize(metadata, dir_name)
        metadata.is_a! Hash
        dir_name.is_a! String

        @data = metadata
        @data['name'] ||= dir_name
        @data['description'] ||= ''

        @data['layout'] ||= 'gallery_index'
        @data['paginate'] ||= 25
        @data['period'] = self.class.parse_period(@data['period'] || '')
        @data['singles'] ||= false
        @data['sizes'] ||= { 'small' => { 'x' => 400, 'y' => 400  } }
      end

      def [](k)
        k.is_a! String
        @data[k]
      end

      def self.parse_period(period)
        period.is_a! String

        components = period.split '-'
        components.map { |c| Date.parse(c) }
      end
    end
  end
end
