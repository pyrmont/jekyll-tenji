require 'jekyll'
require 'pathname'
require 'tenji/gallery'
require 'tenji/generator/gallery'
require 'tenji/refinements'

module Tenji
  class Generator < Jekyll::Generator
    using Tenji::Refinements

    GALLERIES_DIR = '_albums'

    safe true

    def generate(site)
      galleries_dir = Pathname.new(site.source) + Tenji::Generator::GALLERIES_DIR
      galleries = init_galleries galleries_dir
      galleries.each do |g|
        gg = Tenji::Generator::Gallery.new g, site, site.source, galleries_dir
        site.pages.concat gg.generate_index
        site.static_files.concat gg.generate_photos
        site.static_files.concat gg.generate_thumbs
      end
    end

    private def init_galleries(dir)
      dir.subdirectories.map do |d|
        Tenji::Gallery.new dir: d
      end
    end
  end
end
