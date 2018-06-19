require 'jekyll'
require 'tenji/refinements'

module Tenji
  class Gallery
    class Metadata < Hash
      using Tenji::Refinements

      def initialize(metadata, dir_name)
        metadata.is_a! Hash
        dir_name.is_a! String

        self.merge! metadata
        self['name'] ||= dir_name
        self['description'] ||= ''

        self['layout'] ||= 'gallery_index'
        self['paginate'] ||= 25
        self['period'] = self.class.parse_period(self['period'] || '')
        self['singles'] ||= false
        self['sizes'] ||= { 'small' => { 'x' => 400, 'y' => 400  } }
      end

      def self.parse_period(period)
        period.is_a! String

        components = period.split '-'
        components.map { |c| Date.parse(c) }
      end
    end
  end
end
