require 'jekyll'
require 'pathname'

module Tenji
  module Page
    class Single < Jekyll::Page
      def initialize(image, site, base, dir, name)
        @site = site
        @base = base
        @dir = dir
        @name = name

        process_name 

        Jekyll::Hooks.trigger :pages, :post_init, self
      end

      private

      def process_name()
        process @name
      end
    end
  end
end
