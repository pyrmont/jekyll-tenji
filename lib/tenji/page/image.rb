module Tenji
  module Page
    class Image < Jekyll::Page
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

      def destination(dest)
        path = site.in_dest_dir(dest, Jekyll::URL.unescape_path(url))
        path = ::File.join(path, "index") if url.end_with?("/")
        path << output_ext unless path.end_with? output_ext
        input = Tenji::Config.dir(:galleries)
        output = Tenji::Config.dir(:galleries, output: true)
        path.gsub(input, output)
      end

      private def process_name()
        process @name
      end
    end
  end
end
