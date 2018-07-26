# frozen_string_literal: true

module Tenji
  class Gallery
    using Tenji::Refinements

    attr_reader :dirnames, :images, :list, :metadata, :text

    DEFAULTS = { 'title' => 'A Gallery',
                 'description' => '',
                 'layout' => 'gallery_index',
                 'cover' => nil,
                 'listed' => true,
                 'paginate' => 25,
                 'quality' => 'original',
                 'individual_pages' => false,
                 'sizes' => { 'small' => { 'x' => 400, 'y' => 400 } } }

    def initialize(dir, list)
      dir.is_a! Pathname
      list.is_a! Tenji::List

      dir.exist!

      @global = Tenji::Config.settings('gallery') || Hash.new

      fm, text = Tenji::Utilities.read_yaml(dir + Tenji::Config.file(:metadata))
      sizes = init_sizes fm
      quality = init_quality fm

      @dirnames = init_dirnames dir
      @list = list
      @images = init_images dir, sizes, quality
      @text = text
      @metadata = init_metadata fm
    end

    def <=>(other)
      other.is_a! Tenji::Gallery

      this_start = @metadata['period']&.first
      other_start = other.metadata['period']&.first

      if this_start == other_start
        other.dirnames['input'] <=> @dirnames['input']
      elsif this_start.nil?
        1
      elsif other_start.nil?
        -1
      else
        other_start <=> this_start
      end
    end

    def to_liquid()
      attrs = { 'content' => @text }
      @metadata.merge(gallery).merge(attrs)
    end

    private def cover()
      if cover = @metadata['cover']
        if index = @images.find_index { |i| i.name == cover }
          @images.at(index)
        else
          Jekyll.logger.warn "Cover image #{cover} doesn't exist"
          nil
        end
      else
        @images.first
      end
    end

    private def gallery()
      { 'cover' => cover,
        'url' => url }
    end

    private def init_dirnames(dir)
      dir.is_a! Pathname

      input_name = dir.basename.to_s
      output_name = input_name.gsub(/^\d+-/, '')

      { 'input' => input_name, 'output' => output_name }
    end

    private def init_images(dir, sizes, quality)
      dir.is_a! Pathname

      images = dir.images.map do |i|
                 Tenji::Image.new i, sizes, self
               end
      images.sort.each.with_index do |i,index|
        i.position = index
      end
    end

    private def init_metadata(frontmatter)
      frontmatter.is_a! Hash
      attrs = { 'images' => @images }
      DEFAULTS.merge(@global).merge(attrs).merge(frontmatter)
    end

    private def init_quality(frontmatter)
      frontmatter.is_a! Hash
      frontmatter['quality'] || @global['quality'] || DEFAULTS['quality']
    end

    private def init_sizes(frontmatter)
      frontmatter.is_a! Hash
      frontmatter['sizes'] || @global['sizes'] || DEFAULTS['sizes']
    end

    private def url()
      galleries = Tenji::Config.dir 'galleries', output: true
      gallery = @dirnames['output']
      name = ""
      "/#{galleries}/#{gallery}/#{name}"
    end
  end
end
