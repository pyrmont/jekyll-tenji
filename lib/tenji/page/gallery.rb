require 'jekyll'
require 'pathname'
require 'tenji/refinements'

module Tenji
  module Page
    class Gallery < Jekyll::Page
      using Tenji::Refinements

      def initialize(gallery, site, base, dir, name)
        gallery.is_a! Tenji::Gallery
        site.is_a! Jekyll::Site
        base.is_a! String
        dir.is_a! String
        name.is_a! String

        @site = site
        @base = base
        @dir = dir
        @name = name

        process_name 
        
        @data = gallery.metadata
        @content = gallery.text
        @images = gallery.images

        Jekyll::Hooks.trigger :pages, :post_init, self
      end

      private

      def process_name()
        process @name
      end
    end
  end
end
