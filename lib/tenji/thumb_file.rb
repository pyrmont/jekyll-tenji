# frozen_string_literal: true

module Tenji
  class ThumbFile < Jekyll::StaticFile
    using Tenji::Refinements

    include Tenji::Processable

    attr_accessor :source_path

    def initialize(site, base, dir, name, source = nil)
      @config = Tenji::Config
      @gallery_name = pathify(dir).name

      @site = site
      @base = base
      @dir = dir
      @name = name
      @path = File.join(base, dir, name)
      @source_path = source

      process_dir config.dir(:thumbs),
                  config.dir(:galleries, :out), 
                  gallery_name,
                  File.join(output_gallery_name, config.dir(:thumbs, :out))

      @relative_path = File.join(@dir, @name)
      @extname = File.extname(@name)
      @data = @site.frontmatter_defaults.all(relative_path, type)
    end

    def to_liquid()
      return @to_liquid unless @to_liquid.nil?

      @data['url'] = url
      super
    end

    def write(dest)
      original_name = @name
      original_path = @path

      config.scale_factors.each do |f|
        @name = @name.append_to_base(config.scale_suffix(f))
        @path = @path.append_to_base(config.scale_suffix(f))
        super(dest)
      end

      @name = original_name
      @path = original_path
    end
  end
end
