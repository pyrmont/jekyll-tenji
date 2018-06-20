module Tenji
  class List
    using Tenji::Refinements

    attr_reader :dirname, :galleries, :metadata, :text

    DEFAULTS = { 'layout' => 'gallery_list', 
                 'title' => 'Photo Albums' } 

    def initialize(dir, options = {})
      dir.is_a! Pathname
      dir.exist!
      options.is_a! Hash

      @dirname = dir.basename.to_s
      @galleries = init_galleries dir

      fm, text = Tenji::Utilities.read_yaml(dir + Tenji::Config.file(:metadata))
      @metadata = init_metadata fm, options
      @text = text
    end

    private def init_galleries(dir)
      dir.is_a! Pathname
      dir.subdirectories.map do |d|
        Tenji::Gallery.new dir: d
      end
    end

    private def init_metadata(frontmatter, options)
      frontmatter.is_a! Hash
      options.is_a! Hash
      DEFAULTS.merge(options).merge(frontmatter)
    end
  end
end
