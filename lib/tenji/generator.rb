module Tenji
  class Generator < Jekyll::Generator
    using Tenji::Refinements

    safe true

    def generate(site)
      site.is_a! Jekyll::Site

      galleries_dir = Pathname.new(site.source) + Tenji::Config.dir(:galleries)
      galleries = init_galleries galleries_dir
      write_thumbnails site, galleries
      generate_galleries site, galleries, galleries_dir
    end

    private def generate_galleries(site, galleries, dir)
      site.is_a! Jekyll::Site
      galleries.is_a! Array
      dir.is_a! Pathname

      galleries.each do |g|
        base = Pathname.new site.source
        gallery_dir = (dir + g.dirname) - site.source
        gg = Tenji::Generator::Gallery.new g, site, base, gallery_dir 
        gg.generate_index site.pages
        gg.generate_photos site.static_files
        gg.generate_thumbs site.static_files
        gg.generate_singles site.pages
      end
    end

    private def init_galleries(dir)
      dir.is_a! Pathname

      dir.subdirectories.map do |d|
        Tenji::Gallery.new dir: d
      end
    end

    private def write_thumbnails(site, galleries)
      site.is_a! Jekyll::Site
      galleries.is_a! Array

      base_dir = Pathname.new(site.source)

      galleries.each do |g|
        prefix_dir = Pathname.new(Tenji::Config.dir(:galleries)) + g.dirname
        g.images.each do |i|
          source = base_dir + prefix_dir + i.name
          output_dir = base_dir + Tenji::Config.dir(:thumbs) + g.dirname
          output_dir.mkpath unless output_dir.exist?
          Tenji::Writer::Thumb.write i.thumbs, source, output_dir, g.metadata['sizes']
        end
      end
    end
  end
end
