module Tenji
  module Page
    class List < Jekyll::Page
      using Tenji::Refinements

      def initialize(list, site, base, dir, name)
        list.is_a! Tenji::List
        site.is_a! Jekyll::Site
        base.is_a! String
        dir.is_a! String
        name.is_a! String

        @site = site
        @base = base
        @dir = dir
        @name = name

        process_name 
        
        @data = list.metadata 
        @content = list.text

        Jekyll::Hooks.trigger :pages, :post_init, self
      end

      def destination(dest)
        dest.is_a! String

        path = site.in_dest_dir(dest, Jekyll::URL.unescape_path(url))
        path = ::File.join(path, "index") if url.end_with?("/")
        path << output_ext unless path.end_with? output_ext
        input = Tenji::Config.dir(:galleries)
        output = Tenji::Config.dir(:galleries, output: true)
        path.sub(input, output)
      end

      private def process_name()
        process @name
      end
    end
  end
end
