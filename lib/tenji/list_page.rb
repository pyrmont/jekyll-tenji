# frozen_string_literal: true

module Tenji
  class ListPage < Jekyll::Page
    using Tenji::Refinements

    include Tenji::Convertible

    def initialize(site, base, dir, name)
      @config = Tenji::Config

			@site = site
      @base = base
      @dir = dir
      @name = name ? name                       : 'index.html'
      @path = name ? File.join(base, dir, name) : ''

      read_file base, dir, name

      process_dir
      process_name 
      
      data.default_proc = proc do |_, key|
        site.frontmatter_defaults.find(File.join(dir, @name), type, key)
      end

      Jekyll::Hooks.trigger :pages, :post_init, self  
    end

    def galleries=(galleries)
      @data['galleries'] = galleries
    end
    
    private def process_dir()
      in_t = config.dir(:galleries).to_s
      out_t = in_t.slice(1..-1)
      @dir = @dir.sub(in_t, out_t)
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
