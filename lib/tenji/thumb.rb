module Tenji
  class Thumb
    using Tenji::Refinements

    attr_reader :dimensions, :name, :size, :source

    def initialize(size, dimensions, source)
      size.is_a! String
      dimensions.is_a! Hash
      source.is_a! Tenji::Image

      @name = Pathname.new(source.name).append_to_base("-#{size}").to_s
      @size = size
      @dimensions = dimensions
      @source = source
    end

    def to_liquid()
      { 'name' => @name,
        'size' => @size,
        'dimensions' => @dimensions,
        'source' => @source
      }
    end
  end
end
