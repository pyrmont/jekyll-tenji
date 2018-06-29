module Tenji
  module File
    class Thumb < Jekyll::StaticFile
      using Tenji::Refinements

      def destination(dest)
        dest.is_a! String

        t_int = Tenji::Config.dir(:thumbs)
        t_ext = Tenji::Config.dir(:thumbs, output: true)
        g_ext = Tenji::Config.dir(:galleries, output: true)

        file = Pathname.new super(dest)
        file = file.sub t_int, g_ext
        (file.parent + t_ext + file.basename).to_s
      end
    end
  end
end
