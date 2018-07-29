# frozen_string_literal: true

module Tenji
  module Page
    class Gallery < Jekyll::Page
      using Tenji::Refinements

      def initialize(gallery, site, base, dir, name, input_dirname)
        gallery.is_a! Tenji::Gallery
        site.is_a! Jekyll::Site
        base.is_a! String
        dir.is_a! String
        name.is_a! String
        input_dirname.is_a! String

        @site = site
        @base = base
        @dir = dir
        @name = name
        @input_dirname = input_dirname

        process_name

        @data = gallery.data
        @content = gallery.text
        
        hidden_message if gallery.hidden?

        Jekyll::Hooks.trigger :pages, :post_init, self
      end

      def path
        ::File.join(@input_dirname, @name)
      end

      private def hidden_message()
        msg = "'#{@data['title']}' is at #{@site.config['url'] + url}"
        Jekyll.logger.info('Hidden gallery:', msg)
      end

      private def process_name()
        process @name
      end
    end
  end
end
