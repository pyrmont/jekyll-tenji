require 'jekyll'
require 'pathname'
require 'tenji/refinements'

module Tenji
  module Page
    class Single < Jekyll::Page
      using Tenji::Refinements

      def initialize(image, site, base, dir, name)
        image.is_a! Tenji::Gallery::Image
        site.is_a! Jekyll::Site
        base.is_a! String
        dir.is_a! String
        name.is_a! String

        @site = site
        @base = base
        @dir = dir
        @name = name + '.html'

        process_name 

        @data = image.metadata
        @content = image.text

        Jekyll::Hooks.trigger :pages, :post_init, self
      end

      private def process_name()
        process @name
      end
    end
  end
end
