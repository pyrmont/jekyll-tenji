module Tenji
  module Page
    class Image < Jekyll::Page
      using Tenji::Refinements

      def initialize(image, site, base, dir, name)
        image.is_a! Tenji::Image
        site.is_a! Jekyll::Site
        base.is_a! String
        dir.is_a! String
        name.is_a! String

        @site = site
        @base = base
        @dir = dir
        @name = ::File.basename(name, '.*') + '.html'

        process_name 

        @data = image.metadata
        @content = image.text

        Jekyll::Hooks.trigger :pages, :post_init, self
      end

      def destination(dest)
        dest.is_a! String

        input = Tenji::Config.dir(:galleries)
        output = Tenji::Config.dir(:galleries, output: true)

        path = super dest
        path.sub input, output
      end

      private def process_name()
        process @name
      end
    end
  end
end
