# frozen_string_literal: true

module Tenji
  class ImagePage < Jekyll::Page
    using Tenji::Refinements

    include Tenji::Processable

    def initialize(site, base, dir, name)
      @config = Tenji::Config
      @gallery_name = pathify(dir).name

      @site = site
      @base = base
      @dir = dir
      @name = name
      @path = File.join(base, dir, name)

      read_file base, dir, name

      process_dir config.dir(:galleries),
                  config.dir(:galleries, :out),
                  gallery_name,
                  output_gallery_name
      process_name 
      
      data.default_proc = proc do |_, key|
        site.frontmatter_defaults.find(File.join(dir, @name), type, key)
      end

      Jekyll::Hooks.trigger :pages, :post_init, self  
    end

    def image=(image)
      @data['image'] = image
    end

    def to_liquid(attrs = nil)
      data['layout'] ||= config.layout(:single, gallery_name)
      data['next'] = data['image'].image_next&.data&.fetch('page')
      data['prev'] = data['image'].image_prev&.data&.fetch('page')
      super(attrs)
    end

    private def read_file(base, dir, name)
      if File.exist?(File.join(base, dir, name))
        read_yaml File.join(base, dir), name
      else
        @content = nil
        @data = Hash.new
      end
    end
  end
end
