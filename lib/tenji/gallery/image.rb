require 'tenji/gallery/image/thumb'
require 'tenji/refinements'

module Tenji
  class Gallery
    class Image
      using Tenji::Refinements

      attr_reader :metadata, :name, :text, :thumbs

      def initialize(file)
        file.is_a! Pathname
        file.exist!
        
        @name = file.basename.to_s
        @thumbs = Tenji::Gallery::Image::Thumb.new

        co_file = file.sub_ext '.md'
        fm, text = Tenji::Gallery.read_yaml co_file
        @metadata = fm
        @text = text
      end
    end
  end
end
