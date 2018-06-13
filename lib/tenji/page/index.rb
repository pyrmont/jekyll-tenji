require 'jekyll'

module Tenji
  module Page
    class Index < Jekyll::PageWithoutFile
      def initialize(site, base, dir, gallery)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'
      end
    end
  end
end

