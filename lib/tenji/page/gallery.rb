require 'jekyll'
require 'pathname'

module Tenji
  module Page
    class Gallery < Jekyll::Page
      def initialize(gallery, site, base, dir, name)
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
