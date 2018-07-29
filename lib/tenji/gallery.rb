# frozen_string_literal: true

module Tenji
  class Gallery
    using Tenji::Refinements

    attr_reader :dirnames, :images, :metadata, :text

    DEFAULTS = { 'title' => 'A Gallery',
                 'description' => '',
                 'layout' => 'gallery_index',
                 'cover' => nil,
                 'hidden' => false,
                 'paginate' => 25,
                 'quality' => 'original',
                 'individual_pages' => false,
                 'sizes' => { 'small' => { 'x' => 400, 'y' => 400 } } }

    def initialize(dir)
      dir.is_a! Pathname

      dir.exist!

      @global = Tenji::Config.settings('gallery') || Hash.new

      fm, text = Tenji::Utilities.read_yaml(dir + Tenji::Config.file(:metadata))
      sizes = init_sizes fm
      quality = init_quality fm

      @images = init_images dir, sizes, quality
      @text = text
      @metadata = init_metadata fm
      @dirnames = init_dirnames dir
    end

    def <=>(other)
      other.is_a! Tenji::Gallery

      if Tenji::Config.sort('period') == :ignore
        ignore_period = true
      else
        this_start = @metadata['period']&.first
        other_start = other.metadata['period']&.first
      end

      name_sort = Tenji::Config.sort('name')
      period_sort = Tenji::Config.sort('period')

      if ignore_period || this_start == other_start
        (@dirnames['input'] <=> other.dirnames['input']) * name_sort
      elsif this_start.nil?
        1
      elsif other_start.nil?
        -1
      else
        (this_start <=> other_start) * period_sort
      end
    end

    def data()
      attrs = { 'cover' => cover(@metadata['cover']),
                'images' => images }
      @metadata.merge attrs
    end

    def hidden?()
      @metadata['hidden']
    end

    def to_liquid()
      attrs = { 'content' => @text,
                'cover' => cover(@metadata['cover']),
                'url' => url }
      @metadata.merge attrs
    end
    
    def url()
      galleries = Tenji::Config.dir 'galleries', output: true
      gallery = @dirnames['output']
      name = ''
      "/#{galleries}/#{gallery}/#{name}"
    end

    private def cover(name)
      return @images.first unless name
      
      @images.find { |i| i.name == name }
    end

    private def init_dirnames(dir)
      dir.is_a! Pathname

      input_name = dir.basename.to_s
      plain_name = input_name.gsub(/^\d+-/, '')
      output_name = if hidden?
                      Base64.urlsafe_encode64(plain_name, padding: false)
                    else
                      plain_name
                    end

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
      DEFAULTS.merge(@global).merge(frontmatter)
    end

    private def init_quality(frontmatter)
      frontmatter.is_a! Hash
      frontmatter['quality'] || @global['quality'] || DEFAULTS['quality']
    end

    private def init_sizes(frontmatter)
      frontmatter.is_a! Hash
      frontmatter['sizes'] || @global['sizes'] || DEFAULTS['sizes']
    end
  end
end
