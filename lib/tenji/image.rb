module Tenji
  class Image
    using Tenji::Refinements

    attr_reader :gallery, :metadata, :name, :text, :thumbs

    DEFAULTS = { 'layout' => 'gallery_image',
                 'title' => 'Image' }

    def initialize(file, sizes, gallery)
      file.is_a! Pathname
      sizes.is_a! Hash
      gallery.is_a! Tenji::Gallery

      file.exist!
      file.file!

      @gallery = gallery
      @name = file.basename.to_s
      @text, @metadata = init_text_and_data file
      @thumbs = init_thumbs sizes
    end

    def <=>(other)
      other.is_a! Tenji::Image
      @name <=> other.name
    end

    def to_liquid()
      attrs = { 'name' => name, 'content' => text, 'thumbs' => thumbs }
      attrs.merge metadata
    end

    private def init_metadata(frontmatter)
      frontmatter.is_a! Hash

      global = Tenji::Config.settings('image') || Hash.new
      attrs = { 'title' => title_from_name }
      DEFAULTS.merge(global).merge(attrs).merge(frontmatter)
    end

    private def init_text_and_data(file)
      file.is_a! Pathname
      co_file = file.sub_ext Tenji::Config.ext(:page)
      fm, text = Tenji::Utilities.read_yaml co_file
      metadata = init_metadata fm
      [ text, metadata ]
    end

    private def init_thumbs(sizes)
      sizes.is_a! Hash

      sizes.keys.reduce(Hash.new) do |memo,s|
        memo.update({ s => Tenji::Thumb.new(s, sizes[s], self) }) 
      end
    end

    private def title_from_name()
      @name.sub /^\d+-/, ''
    end
  end
end
