# frozen_string_literal: true

module Tenji
  class GalleryPage < Jekyll::Page
    using Tenji::Refinements

    include Tenji::Pageable
    include Tenji::Processable

    def initialize(site, base, dir, name)
      @config = Tenji::Config
      @gallery_name = pathify(dir).name

			@site = site
      @base = base
      @dir = dir
      @name = name ? name                       : 'index.html'
      @path = name ? File.join(base, dir, name) : ''

      read_file base, dir, name
      add_config

      process_dir config.dir(:galleries), 
                  config.dir(:galleries, :out), 
                  gallery_name, 
                  output_gallery_name
      process_name

      paginate config.items_per_page(gallery_name)
      
      data.default_proc = proc do |_, key|
        site.frontmatter_defaults.find(File.join(dir, @name), type, key)
      end

      Jekyll::Hooks.trigger :pages, :post_init, self  
    end

    def initialize_copy(source)
      super
      @data = source.data.dup
    end

    def <=>(other)
      this_start = data['period']&.first
      other_start = other.data['period']&.first

      name_sort = config.sort('name')
      time_sort = config.sort('time')

      if time_sort == :ignore || this_start == other_start
        (gallery_name <=> other.gallery_name) * name_sort
      elsif this_start.nil?
        1
      elsif other_start.nil?
        -1
      else
        (this_start <=> other_start) * time_sort 
      end
    end

    def cover=(cover)
      data['cover'] = cover
    end

    def images=(images)
      data['images'] = images
    end

    def items()
      data['images']
    end

    def items=(items)
      data['images'] = items
    end

    def to_liquid(attrs = nil)
      data['layout'] ||= config.layout(:gallery, gallery_name)
      super(attrs)
    end

    private def add_config()
      config.add_config gallery_name, settings
    end

    private def parse_period(period)
      components = period.split '-'
      components.map { |c| Date.parse(c.strip) }
    end

    private def read_file(base, dir, name) 
      if name.nil?
        @content = nil
        @data = Hash.new
      else
        read_yaml File.join(base, dir), name
        data['period'] = parse_period data['period'] if data['period']
      end  
    end

    private def settings()
      data.select { |k,v| config.settings(:gallery).key?(k) }
    end
  end
end
