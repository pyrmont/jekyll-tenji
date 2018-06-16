require 'tenji/gallery/image/thumb'

module Tenji
  class Gallery
    class Image

      attr_accessor :name, :thumbs

      def initialize(file)
        msg = "The file #{file} doesn't exist."
        raise StandardError, msg unless file.exist?

        @name = file.basename.to_s
        @thumbs = Tenji::Gallery::Image::Thumb.new file
      end
    end
  end
end
