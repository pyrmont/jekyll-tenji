# frozen_string_literal: true

module Tenji
  module File
    class Thumb < Jekyll::StaticFile
      using Tenji::Refinements

      def initialize(site, base, dir, name, gallery_name)
        @gallery_name = gallery_name
        super site, base, dir, name
      end

      def path
        thumbs_name = Tenji::Config.dir 'thumbs'
        ::File.join(*[@base, thumbs_name, @gallery_name, @name].compact)
      end
    end
  end
end
