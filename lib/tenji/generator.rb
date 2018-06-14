require 'jekyll'
require 'pathname'
require 'tenji/gallery'
require 'tenji/page/gallery'
require 'tenji/refinements'

module Tenji
  class Generator < Jekyll::Generator
    using Tenji::Refinements

    GALLERIES_DIR = '_albums'

    safe true

    def generate(site)
      dir = Pathname.new(site.source) + Tenji::Generator::GALLERIES_DIR
      generate_pages site, dir
    end

    private

    def generate_pages(site, dir)
      dir.subdirectories.each do |d|
        g = Tenji::Gallery.new dir: d
        p = Tenji::Page::Gallery.new site, site.source, d.basename.to_s, g
        site.pages << p
      end
    end
  end
end
