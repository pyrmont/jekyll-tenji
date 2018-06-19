require 'pathname'
require 'tenji/refinements'

module Tenji
  class Gallery
    class Image
      class Thumb
        using Tenji::Refinements

        attr_reader :files

        def initialize()
          @files = Hash.new
        end

        def [](k)
          k.is_a! String
          @files[k]
        end

        def []=(k, v)
          k.is_a! String
          @files[k] = v
        end
      end
    end
  end
end
