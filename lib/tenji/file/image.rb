# frozen_string_literal: true

module Tenji
  module File
    class Image < Jekyll::StaticFile
      using Tenji::Refinements

      def initialize(site, base, dir, name, gallery_name)
        @gallery_name = gallery_name
        super site, base, dir, name
      end

      def path
        galleries_name = Tenji::Config.dir 'galleries'
        ::File.join(*[@base, galleries_name, @gallery_name, @name].compact)
      end
    end
  end
end
