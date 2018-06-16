require 'jekyll'
require 'pathname'
require 'tenji/gallery'
require 'tenji/generator/gallery'
require 'tenji/refinements'
require 'tenji/writer/thumbs'

module Tenji
  class Generator < Jekyll::Generator
    using Tenji::Refinements

    GALLERIES_DIR = '_albums'

    safe true

    def generate(site)
      galleries_dir = Pathname.new(site.source) + Tenji::Generator::GALLERIES_DIR
      galleries = init_galleries galleries_dir
      write_thumbnails site, galleries
      generate_galleries site, galleries, galleries_dir
    end

    private def generate_galleries(site, galleries, dir)
      galleries.each do |g|
        gg = Tenji::Generator::Gallery.new g, site, site.source, dir
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

    private def write_thumbnails(site, galleries)
      galleries.each do |g|
        g.images.each do |i|
          output_dir = Pathname.new site.dest
          Tenji::Writer::Thumbs.write i.thumbs, output_dir, g.metadata['sizes']
        end
      end
    end
  end
end
