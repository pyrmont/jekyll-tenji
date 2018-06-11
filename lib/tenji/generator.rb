require 'pathname'
require 'tenji/refinements'

module Tenji
  class Generator < Jekyll::Generator
    using Tenji::Refinements

    safe true

    def generate(site)
      galleries_dir = Pathname.new(site.source) + GALLERY_BASE_DIRNAME
      generate_pages site, galleries_dir
    end

    def generate_pages(site, dir)
      dir.subdirectories.each do |d|
        g = Gallery.new dir: d
      end
    end
  end
end
