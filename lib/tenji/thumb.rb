module Tenji
  class Thumb
    using Tenji::Refinements

    attr_reader :files, :image

    def initialize(sizes, image)
      sizes.is_a! Hash
      image.is_a! Tenji::Image
      @files = sizes
      @image = image
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
