module Tenji
  class Generator < Jekyll::Generator
    using Tenji::Refinements

    safe true

    def generate(site)
      site.is_a! Jekyll::Site

      galleries_dir = Pathname.new(site.source) + Tenji::Config.dir(:galleries)
      list = init_list galleries_dir

      write_thumbnails site, list.galleries
      generate_list site, list, galleries_dir
      generate_galleries site, list.galleries, galleries_dir
    end

    private def generate_galleries(site, galleries, dir)
      site.is_a! Jekyll::Site
      galleries.is_a! Array
      dir.is_a! Pathname

      base = Pathname.new site.source
      
      galleries.each do |g|
        gallery_dir = (dir + g.dirname) - site.source
        gg = Tenji::Generator::Gallery.new g, site, base, gallery_dir 
        gg.generate_index site.pages
        gg.generate_images site.static_files
        gg.generate_thumbs site.static_files
        gg.generate_singles site.pages
      end
    end

    private def generate_list(site, list, dir)
      site.is_a! Jekyll::Site
      list.is_a! Tenji::List
      dir.is_a! Pathname

      base = Pathname.new site.source
      prefix_dir = dir - site.source

      gl = Tenji::Generator::List.new list, site, base, prefix_dir
      gl.generate_index site.pages
    end

    private def init_list(dir)
      dir.is_a! Pathname
      Tenji::List.new dir
    end

    private def write_thumbnails(site, galleries)
      site.is_a! Jekyll::Site
      galleries.is_a! Array

      base_dir = Pathname.new site.source

      galleries.each do |g|
        input_dir = base_dir + Tenji::Config.dir(:galleries) + g.dirname
        output_dir = base_dir + Tenji::Config.dir(:thumbs) + g.dirname
        output_dir.mkpath unless output_dir.exist?
        g.images.each do |i|
          source_file = input_dir + i.name
          i.thumbs.each do |t|
            Tenji::Writer::Thumb.write t, source_file, output_dir
          end
        end
      end
    end
  end
end
