module Tenji
  class Gallery
    class Image
      class Thumb
        attr_reader :files, :source

        def initialize(source)
          @files = Hash.new
          @source = source
        end

        def [](k)
          @files[k]
        end

        def []=(k, v)
          @files[k] = v
        end
      end
    end
  end
end