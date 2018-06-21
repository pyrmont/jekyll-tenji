module Tenji
  class Thumb
    using Tenji::Refinements

    attr_reader :files

    def initialize(sizes)
      sizes.is_a! Hash
      @files = sizes
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
