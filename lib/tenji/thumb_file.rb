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
      @source_path = source ? File.join(base, source) : nil

      process_dir config.dir(:thumbs),
                  config.dir(:galleries, :out), 
                  gallery_name,
                  File.join(output_gallery_name, config.dir(:thumbs, :out))
    end
  end
end
