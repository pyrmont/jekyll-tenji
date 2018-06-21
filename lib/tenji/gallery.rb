module Tenji
  class Gallery
    using Tenji::Refinements

    attr_reader :dirname, :images, :list, :metadata, :text

    DEFAULTS = { 'description' => '',
                 'layout' => 'gallery_index',
                 'listed' => true,
                 'paginate' => 25,
                 'singles' => false,
                 'sizes' => { 'small' => { 'x' => 400, 'y' => 400 } }
               }

    def initialize(dir, list)
      dir.is_a! Pathname
      dir.exist!
      list.is_a! Tenji::List

      @list = list
      @dirname = dir.basename.to_s
      
      fm, text = Tenji::Utilities.read_yaml(dir + Tenji::Config.file(:metadata))
      @metadata = init_metadata fm
      @text = text
      
      @images = init_images dir
      @metadata['images'] = @images
    end

    private def init_images(dir)
      dir.is_a! Pathname

      dir.images.map do |i|
        Tenji::Image.new i, @metadata['sizes'], self
      end
    end

    private def init_metadata(frontmatter)
      frontmatter.is_a! Hash
      
      global = Tenji::Config.settings('gallery') || Hash.new
      attributes = { 'images' => @images, 'list' => @list, 'name' => @dirname }
      DEFAULTS.merge(attributes).merge(global).merge(frontmatter)
    end
  end
end
