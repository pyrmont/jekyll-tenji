# frozen_string_literal: true

module Tenji
  class ThumbFile < Jekyll::StaticFile
    using Tenji::Refinements

    include Tenji::Convertible

    attr_accessor :source_path

    def initialize(site, base, dir, name, source = nil)
      @config = Tenji::Config
      @gallery_name = pathify(dir).name

			@site = site
      @base = base
      @dir = dir
      @name = name
      @path = File.join(base, dir, name)
      @source_path = source ? File.join(base, source) : nil

      process_dir
    end
    
    private def process_dir()
      in_t = config.dir(:thumbs).to_s
      out_t = config.dir(:galleries).to_s.slice(1..-1)
      in_g = gallery_name
      out_g = File.join(output_gallery_name(in_g),
                        config.dir(:thumbs).to_s.slice(1..-1))
      @dir = @dir.sub(in_t, out_t).sub(in_g, out_g)
    end
  end
end
