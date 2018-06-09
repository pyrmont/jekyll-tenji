require 'pathname'
require 'yaml'

module Tenji
  class GalleryMetadata
    attr_accessor :name, :description, :period, :singles, :paginate

    def initialize(file)
      metadata = file.exist? ? YAML.load_file(file.realpath) : {}
      @name = metadata[:name] || file.parent.relative_path_from(file.parent.parent)
      @description = metadata[:description] || ''
      @period = metadata[:period] || ''
      @singles = metadata[:singles] || false
      @paginate = metadata[:paginate] || 25
    end
  end

  class GalleryPageGenerator < Jekyll::Generator
    safe true
    
    attr_accessor :gallery_dir

    def generate(site)
      base_dir = Pathname.new site.source
      @gallery_dir = base_dir + '_galleries'
      gp = gallery_pages dirs: gallery_dirs
    end

    def gallery_dirs
      @gallery_dir.children.select { |c| c.directory? }
    end

    def gallery_pages(dirs:)
      dirs.each do |d|
        metadata = gallery_metadata dir: d
        images = gallery_images dir: d
        puts metadata.inspect
      end
    end

    def gallery_images(dir:)
      dir.children.select { |f| f.extname == '.jpg' }
    end

    def gallery_metadata(dir:)
      file_path = dir + '/_gallery.yml'
      gm = GalleryMetadata.new file_path
    end
  end
end
