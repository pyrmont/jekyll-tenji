module Tenji
  class Gallery
    using Tenji::Refinements

    attr_reader :dirname, :images, :metadata, :text

    DEFAULTS = { 'description' => '',
                 'layout' => 'gallery_index',
                 'listed' => true,
                 'paginate' => 25,
                 'singles' => false,
                 'sizes' => { 'small' => { 'x' => 400, 'y' => 400 } }
               }

    def initialize(dir:)
      dir.is_a! Pathname
      dir.exist!

      @dirname = dir.basename.to_s

      fm, text = Tenji::Utilities.read_yaml(dir + Tenji::Config.file(:metadata))
      @metadata = init_metadata fm, dir
      @text = text

      @images = init_images dir
    end

    private def init_images(dir)
      dir.is_a! Pathname

      dir.images.map do |i|
        Tenji::Image.new i, @metadata['sizes']
      end
    end

    private def init_metadata(frontmatter, dir, options = {})
      frontmatter.is_a! Hash
      dir.is_a! Pathname
      options.is_a! Hash
      
      frontmatter['name'] ||= dir.basename.to_s
      DEFAULTS.merge(options).merge(frontmatter)
    end
  end
end
