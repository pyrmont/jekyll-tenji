# frozen_string_literal: true

module Tenji
  class Thumb
    using Tenji::Refinements

    attr_reader :constraints, :name, :resize_function, :size, :source

    def initialize(size, constraints, resize_function, source)
      size.is_a! String
      constraints.is_a! Hash
      resize_function.is_a! String
      source.is_a! Tenji::Image

      @name = source.name.append_to_base "-#{size}"
      @size = size
      @constraints = constraints
      @resize_function = resize_function.downcase
      @source = source
    end

    def to_liquid()
      { 'name' => @name,
        'url' => url,
        'size' => @size,
        'source' => @source }
    end

    private def url()
      galleries = Tenji::Config.dir 'galleries', output: true
      gallery = @source.gallery.dirnames['output']
      thumbs = Tenji::Config.dir 'thumbs', output: true
      "/#{galleries}/#{gallery}/#{thumbs}/#{@name}"
    end
  end
end
