require 'tenji/gallery/image/thumb'
require 'tenji/refinements'

module Tenji
  class Gallery
    class Image
      using Tenji::Refinements

      attr_reader :name, :thumbs

      def initialize(file)
        file.is_a! Pathname
        file.exist!
        
        @name = file.basename.to_s
        @thumbs = Tenji::Gallery::Image::Thumb.new file
      end
    end
  end
end
