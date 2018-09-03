# frozen_string_literal: true

module Tenji
  class ListPage < Jekyll::Page
    using Tenji::Refinements

    include Tenji::Pageable
    include Tenji::Processable

    def initialize(site, base, dir, name)
      @config = Tenji::Config

			@site = site
      @base = base
      @dir = dir
      @name = name ? name                       : 'index.html'
      @path = name ? File.join(base, dir, name) : ''

      read_file base, dir, name

      process_dir config.dir(:galleries), config.dir(:galleries, :out)
      process_name 
      
      paginate config.items_per_page
      
      data.default_proc = proc do |_, key|
        site.frontmatter_defaults.find(File.join(dir, @name), type, key)
      end

      Jekyll::Hooks.trigger :pages, :post_init, self  
    end

    def galleries=(galleries)
      @data['galleries'] = galleries
    end

    def items()
      data['galleries']
    end

    def items=(galleries)
      data['galleries'] = galleries
    end
    
    def to_liquid(attrs = nil)
      data['layout'] ||= config.layout(:list)
      super(attrs)
    end

    private def read_file(base, dir, name) 
      if name.nil?
        @content = ''
        @data = Hash.new
      else
        read_yaml File.join(base, dir), name
      end
    end
  end
end
