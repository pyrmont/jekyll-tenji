# frozen_string_literal: true

module Tenji
  class List
    using Tenji::Refinements

    attr_reader :dirname, :galleries, :metadata, :text

    DEFAULTS = { 'title' => 'Photo Albums',
                 'layout' => 'gallery_list' }

    def initialize(dir, galleries)
      dir.is_a! Pathname
      galleries.is_a! Array

      dir.exist!
      
      @global = Tenji::Config.settings('list') || Hash.new

      fm, text = Tenji::Utilities.read_yaml(dir + Tenji::Config.file(:metadata))

      @dirname = dir.basename.to_s
      @galleries = galleries

      @text = text
      @metadata = init_metadata fm
    end

    def to_liquid()
      { 'galleries' => @galleries }
    end

    private def init_metadata(frontmatter)
      frontmatter.is_a! Hash
      attrs = { 'galleries' => @galleries }
      DEFAULTS.merge(@global).merge(attrs).merge(frontmatter)
    end
  end
end
