module Tenji
  class List
    using Tenji::Refinements

    attr_reader :dirname, :galleries, :metadata, :text

    DEFAULTS = { 'layout' => 'gallery_list', 
                 'title' => 'Photo Albums' } 

    def initialize(dir)
      dir.is_a! Pathname
      dir.exist!

      @dirname = dir.basename.to_s
      @galleries = init_galleries dir

      fm, text = Tenji::Utilities.read_yaml(dir + Tenji::Config.file(:metadata))
      @metadata = init_metadata fm
      @text = text
    end

    private def init_galleries(dir)
      dir.is_a! Pathname
      dir.subdirectories.map do |d|
        Tenji::Gallery.new d, self
      end
    end

    private def init_metadata(frontmatter)
      frontmatter.is_a! Hash

      global = Tenji::Config.settings('list') || Hash.new
      attributes = { 'galleries' => @galleries }
      DEFAULTS.merge(attributes).merge(global).merge(frontmatter)
    end
  end
end
