# frozen_string_literal: true

module Tenji
  module File
    class Thumb < Jekyll::StaticFile
      using Tenji::Refinements

      def initialize(site, base, dir, name, input_dirname)
        @input_dirname = input_dirname
        super site, base, dir, name
      end

      def path 
        ::File.join(*[@base, @input_dirname, @name].compact)
      end
    end
  end
end
