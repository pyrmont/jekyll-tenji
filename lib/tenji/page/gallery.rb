require 'jekyll'
require 'pathname'

module Tenji
  module Page
    class Gallery < Jekyll::Page
      def initialize(site, base, dir, gallery)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        path = init_paths base, dir, @name
        process_name 
        read_yaml path[:file]

        Jekyll::Hooks.trigger :pages, :post_init, self
      end

      private

      def init_paths(base, dir, name)
        path = Hash.new
        path[:base] = Pathname.new base
        path[:dir] = path[:base] + dir
        path[:file] = path[:dir] + name
        path
      end

      def process_name()
        process @name
      end

      def read_yaml(file)


      end
    end
  end
end

