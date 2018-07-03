module Tenji
  class Gallery
    using Tenji::Refinements

    attr_reader :dirname, :images, :list, :metadata, :text

    DEFAULTS = { 'title' => 'A Gallery',
                 'description' => '',
                 'layout' => 'gallery_index',
                 'listed' => true,
                 'originals' => true,
                 'paginate' => 25,
                 'individual_pages' => false,
                 'sizes' => { 'small' => { 'x' => 400, 'y' => 400 } }
               }

    def initialize(dir, list)
      dir.is_a! Pathname
      dir.exist!
      list.is_a! Tenji::List
      
      @global = Tenji::Config.settings('gallery') || Hash.new

      fm, text = Tenji::Utilities.read_yaml(dir + Tenji::Config.file(:metadata))
      sizes = init_sizes fm

      @list = list
      @images = init_images dir, sizes
      @dirname = dir.basename.to_s
      @metadata = init_metadata fm
      @text = text
    end

    def to_liquid()
      attrs = { 'dirname' => @dirname, 'content' => @text, 'cover' => @images.first }
      attrs.merge @metadata
    end

    private def init_images(dir, sizes)
      dir.is_a! Pathname

      images = dir.images.map do |i|
                 Tenji::Image.new i, sizes, self
               end
      images.sort
    end

    private def init_metadata(frontmatter)
      frontmatter.is_a! Hash
      attrs = { 'images' => @images }
      DEFAULTS.merge(@global).merge(attrs).merge(frontmatter)
    end

    private def init_sizes(frontmatter)
      frontmatter.is_a! Hash
      frontmatter['sizes'] || @global['sizes'] || DEFAULTS['sizes']
    end
  end
end
