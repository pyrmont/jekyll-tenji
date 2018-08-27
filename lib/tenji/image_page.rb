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

      process_dir
      process_name 
      
      data.default_proc = proc do |_, key|
        site.frontmatter_defaults.find(File.join(dir, @name), type, key)
      end

      Jekyll::Hooks.trigger :pages, :post_init, self  
    end

    def image=(image)
      @data['image'] = image
    end

    private def read_file(base, dir, name) 
      read_yaml File.join(base, dir), name
    end
  end
end
