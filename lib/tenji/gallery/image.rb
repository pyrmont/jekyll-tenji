module Tenji
  class Gallery
    class Image
      using Tenji::Refinements

      attr_reader :metadata, :name, :text, :thumbs

      def initialize(file, sizes)
        file.is_a! Pathname
        file.exist!
        sizes.is_a! Hash

        @name = file.basename.to_s
        @thumbs = init_thumbs file.basename, sizes.keys

        co_file = file.sub_ext Tenji::Config.ext(:page)
        fm, text = Tenji::Utilities.read_yaml co_file
        @metadata = fm
        @text = text
      end

      def init_thumbs(filename, keys)
        filename.is_a! Pathname
        keys.is_a! Array

        name = filename.sub_ext('')
        ext = '.jpg'
        sizes = Hash.new
        keys.each do |k|
          sizes[k] = name.to_s + '-' + k + ext
        end
        Tenji::Gallery::Image::Thumb.new sizes 
      end
    end
  end
end
