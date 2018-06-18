require 'pathname'
require 'tenji/refinements'

module Tenji
  class Gallery
    class Image
      class Thumb
        using Tenji::Refinements

        attr_reader :files, :source

        def initialize(source)
          source.is_a! Pathname
          source.exist!

          @files = Hash.new
          @source = source
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
