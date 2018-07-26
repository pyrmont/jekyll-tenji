# frozen_string_literal: true

module Tenji
  module Page
    class Image < Jekyll::Page
      using Tenji::Refinements

      def initialize(image, site, base, dir, name, input_dirname)
        image.is_a! Tenji::Image
        site.is_a! Jekyll::Site
        base.is_a! String
        dir.is_a! String
        name.is_a! String
        input_dirname.is_a! String

        @site = site
        @base = base
        @dir = dir
        @name = ::File.basename(name, '.*') + '.html'
        @input_dirname = input_dirname

        process_name

        @data = image.data
        @content = image.text

        Jekyll::Hooks.trigger :pages, :post_init, self
      end

      def path
        ::File.join(@input_dirname, @name)
      end

      private def process_name()
        process @name
      end
    end
  end
end
