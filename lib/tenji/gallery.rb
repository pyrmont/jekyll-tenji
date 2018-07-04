module Tenji
  class Gallery
    using Tenji::Refinements

    attr_reader :cover, :dirname, :images, :list, :metadata, :text

    DEFAULTS = { 'title' => 'A Gallery',
                 'description' => '',
                 'layout' => 'gallery_index',
                 'cover' => nil,
                 'listed' => true,
                 'originals' => true,
                 'paginate' => 25,
                 'individual_pages' => false,
                 'sizes' => { 'small' => { 'x' => 400, 'y' => 400 } }
               }

    def initialize(dir, list)
      dir.is_a! Pathname
      list.is_a! Tenji::List

      dir.exist!

      @global = Tenji::Config.settings('gallery') || Hash.new

      fm, text = Tenji::Utilities.read_yaml(dir + Tenji::Config.file(:metadata))
      sizes = init_sizes fm

      @dirname = dir.basename.to_s
      @list = list
      @images = init_images dir, sizes
      @cover = init_cover fm
      
      @text = text
      @metadata = init_metadata fm
    end

    def <=>(other)
      other.is_a! Tenji::Gallery

      this_start = @metadata['period']&.first
      other_start = other.metadata['period']&.first

      if this_start.nil? && other_start.nil?
        @dirname <=> other.dirname
      elsif this_start.nil?
        1
      elsif other_start.nil?
        -1
      elsif this_start == other_start
        @dirname <=> other.dirname
      else
        other_start <=> this_start
      end
    end

    def to_liquid()
      attrs = { 'dirname' => @dirname,
                'content' => @text,
                'cover' => @cover }
      @metadata.merge attrs
    end

    private def init_cover(frontmatter)
      frontmatter.is_a! Hash

      if cover = frontmatter['cover']
        begin
          @images.at(@images.find_index { |i| i.name == cover }) 
        rescue TypeError => e
          Jekyll.logger.warn "Cover image #{cover} doesn't exist"
          nil
        end
      else
        @images.first
      end
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
