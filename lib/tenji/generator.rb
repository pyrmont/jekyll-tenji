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
      site.is_a! Jekyll::Site

      galleries_dir = Pathname.new(site.source) + Tenji::Generator::GALLERIES_DIR
      galleries = init_galleries galleries_dir
      write_thumbnails site, galleries
      generate_galleries site, galleries, galleries_dir
    end

    private def generate_galleries(site, galleries, dir)
      site.is_a! Jekyll::Site
      galleries.is_a! Array
      dir.is_a! Pathname

      galleries.each do |g|
        source = Pathname.new site.source
        gg = Tenji::Generator::Gallery.new g, site, source, dir
        gg.generate_index site.pages
        gg.generate_photos site.static_files
        gg.generate_thumbs site.static_files
      end
    end

    private def init_galleries(dir)
      dir.is_a! Pathname

      dir.subdirectories.map do |d|
        Tenji::Gallery.new dir: d
      end
    end

    private def write_thumbnails(site, galleries)
      site.is_a! Jekyll::Site
      galleries.is_a! Array

      galleries.each do |g|
        g.images.each do |i|
          output_dir = Pathname.new site.dest
          Tenji::Writer::Thumbs.write i.thumbs, output_dir, g.metadata['sizes']
        end
      end
    end
  end
end
