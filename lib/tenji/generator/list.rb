module Tenji
  class Generator < Jekyll::Generator
    class List
      using Tenji::Refinements

      attr_reader :list, :site, :base, :prefix_path

      def initialize(list, site, base, prefix_path)
        list.is_a! Tenji::List
        site.is_a! Jekyll::Site
        base.is_a! Pathname
        prefix_path.is_a! Pathname

        @list = list
        @site = site
        @base = base.to_s
        @prefix_path = prefix_path.to_s
      end

      def generate_index(pages)
        pages.is_a! Array
        name = 'index' + Tenji::Config.ext(:page, output: true)
        pages << Tenji::Page::List.new(@list, @site, @base, @prefix_path, name)
      end
    end
  end
end
