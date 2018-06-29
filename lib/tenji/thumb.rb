module Tenji
  class Thumb
    using Tenji::Refinements

    attr_reader :dimensions, :name, :size, :source

    def initialize(size, dimensions, source)
      size.is_a! String
      dimensions.is_a! Hash
      source.is_a! Tenji::Image
     
      @name = init_name size, Pathname.new(source.name)
      @size = size
      @dimensions = dimensions
      @source = source
    end

    private def init_name(size, basename)
      basename.sub_ext('').to_s + "-#{size}.jpg"
    end
  end
end
