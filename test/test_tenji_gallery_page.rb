require 'test_helper'

describe Tenji::GalleryPage do
  before do
    @config = Tenji::Config
    @config.configure({ 'galleries_dir' => '_albums' })
    @site = TestSite.site source: 'test/data/', dest: 'tmp'
    @base = @site.source
    @obj = Tenji::GalleryPage.new @site, @base, '_albums/01-gallery', nil
  end

  after do
    @config.reset
  end
    
  describe "#initialize" do
    it "instantiates a Tenji::GalleryPage object for a directory with an index file" do
      obj = Tenji::GalleryPage.new @site, @base, '_albums/gallery', 'index.md'
      assert_equal Tenji::GalleryPage, obj.class
      assert_equal 'gallery', obj.gallery_name
      assert_equal File.join(@base, '_albums/gallery', 'index.md'), obj.path
      assert_equal 'index', obj.basename
      assert_equal '.md', obj.ext
      assert_equal '/albums/gallery/', obj.dir
      assert_equal "This is some content.\n", obj.content
      assert_equal 'Test Gallery', obj.data['title']
      assert_equal 'An example of a gallery.', obj.data['description']
      assert_equal [ Date.new(2018, 01, 01), Date.new(2018, 01, 05) ], obj.data['period']
      assert_equal 15, obj.instance_variable_get(:@__items_per_page__)
    end
    
    it "instantiates a Tenji::GalleryPage object for a directory without an index file" do
      obj = Tenji::GalleryPage.new @site, @base, '_albums/gallery2', nil 
      assert_equal Tenji::GalleryPage, obj.class
      assert_equal 'gallery2', obj.gallery_name
      assert_equal '', obj.path
      assert_equal 'index', obj.basename
      assert_equal '.html', obj.ext
      assert_equal '/albums/gallery2/', obj.dir 
      assert_nil obj.content
      assert_equal 25, obj.instance_variable_get(:@__items_per_page__)
    end

    it "instantiates a Tenji::GalleryPage object for a directory without a numeric prefix" do
      obj = Tenji::GalleryPage.new @site, @base, '_albums/01-gallery', nil 
      assert_equal Tenji::GalleryPage, obj.class
      assert_equal '01-gallery', obj.gallery_name
      assert_equal '', obj.path
      assert_equal 'index', obj.basename
      assert_equal '.html', obj.ext
      assert_equal '/albums/gallery/', obj.dir 
      assert_nil obj.content
      assert_equal 25, obj.instance_variable_get(:@__items_per_page__)
    end

    it "instantiates a Tenji::GalleryPage object for a hidden directory" do
      @config.debug['gallery_settings']['hidden'] = true
      obj = Tenji::GalleryPage.new @site, @base, '_albums/gallery', nil 
      assert_equal Tenji::GalleryPage, obj.class
      assert_equal 'gallery', obj.gallery_name
      assert_equal '', obj.path
      assert_equal 'index', obj.basename
      assert_equal '.html', obj.ext
      assert_equal '/albums/Z2FsbGVyeQ/', obj.dir 
      assert_nil obj.content
      assert_equal 25, obj.instance_variable_get(:@__items_per_page__)
    end
  end

  describe "#initialize_copy" do
    it "instantiates a copy" do
      double = @obj.dup
      double.data['foo'] = 'bar'
      refute @obj.data.key?('foo')
    end
  end

  describe "#<=>" do
    before do
      factory = TestFactory.new @site, galleries: [ '00-gallery/', '01-gallery/', '02-gallery/' ]  
      @comps = factory.make :gallery_pages, flatten: true
    end

    it "compares itself with Tenji::Gallery objects with no period" do
      assert_equal 1, @obj <=> @comps[0]
      assert_equal 0, @obj <=> @comps[1]
      assert_equal -1, @obj <=> @comps[2]
      
      @obj.data['period'] = [ Date.new(1970, 1, 1) ]

      assert_equal -1, @obj <=> @comps[0]
      assert_equal -1, @obj <=> @comps[1]
      assert_equal -1, @obj <=> @comps[2]

      @config.set 'sort', { 'name' => 'asc', 'time' => 'ignore' }

      assert_equal 1, @obj <=> @comps[0]
      assert_equal 0, @obj <=> @comps[1]
      assert_equal -1, @obj <=> @comps[2] 
    end

    it "compares itself with Tenji::Gallery objects with a period" do
      @comps[0].data['period'] = [ Date.new(1870, 1, 1) ]
      @comps[1].data['period'] = [ Date.new(1970, 1, 1) ]
      @comps[2].data['period'] = [ Date.new(2070, 1, 1) ]

      assert_equal 1, @obj <=> @comps[0]
      assert_equal 1, @obj <=> @comps[1]
      assert_equal 1, @obj <=> @comps[2]
      
      @obj.data['period'] = [ Date.new(1970, 1, 1) ]

      assert_equal -1, @obj <=> @comps[0]
      assert_equal 0, @obj <=> @comps[1]
      assert_equal 1, @obj <=> @comps[2]
      
      @config.set 'sort', { 'name' => 'asc', 'time' => 'ignore' }
      
      assert_equal 1, @obj <=> @comps[0]
      assert_equal 0, @obj <=> @comps[1]
      assert_equal -1, @obj <=> @comps[2]

      @config.set 'sort', { 'name' => 'desc', 'time' => 'ignore' }

      assert_equal -1, @obj <=> @comps[0]
      assert_equal 0, @obj <=> @comps[1]
      assert_equal 1, @obj <=> @comps[2]

      @config.set 'sort', { 'name' => 'asc', 'time' => 'asc' }

      assert_equal 1, @obj <=> @comps[0]
      assert_equal 0, @obj <=> @comps[1]
      assert_equal -1, @obj <=> @comps[2]
    end
  end

  describe "#cover=" do
    it "assigns the parameter" do
      cover = Object.new
      @obj.cover = cover
      assert_equal cover, @obj.data['cover']
    end
  end 
  
  describe "#images=" do
    it "assigns the parameter" do
      images = Object.new
      @obj.images = images
      assert_equal images, @obj.data['images']
    end
  end

  describe "#items" do
    it "gets the pageable items" do
      assert_nil @obj.items

      images = Object.new
      @obj.instance_variable_get(:@data)['images'] = images

      assert_equal images, @obj.items
    end
  end
  
  describe "#items=" do
    it "sets the pageable items" do
      assert_nil @obj.instance_variable_get(:@data)['images']

      images = Object.new
      @obj.items = images

      assert_equal images, @obj.instance_variable_get(:@data)['images']
    end
  end
  
  describe "#write" do
    it "uses the method defined on Tenji::Pageable::Page" do
      method = @obj.method(:write)
      assert_equal Tenji::Pageable::Page, method.owner
    end

    it "uses the method defined on Jekyll::Convertible" do
      @config.set [ 'gallery_settings', 'images_per_page' ], false
      @obj = Tenji::GalleryPage.new @site, @base, '_albums/other', nil
      
      method = @obj.method(:write)
      assert_equal Jekyll::Convertible, method.owner
    end

    describe "with a modified GalleryPage class" do
      before do
        Jekyll::Convertible.alias_method :orig_write, :write
        Jekyll::Convertible.class_eval { def write(dest) puts destination(dest) end }

        @config.set [ 'gallery_settings', 'images_per_page' ], 1
        factory = TestFactory.new @site, images: [ 'gallery/1.jpg', 'gallery/2.jpg', 'gallery/3.jpg' ]
        
        @obj = Tenji::GalleryPage.new @site, @base, '_albums/gallery', nil
        @obj.images = factory.make :image_files, flatten: true  
      end

      after do
        Jekyll::Convertible.alias_method :write, :orig_write
        Jekyll::Convertible.remove_method :orig_write
      end

      it "outputs the paths to which it will write its pages" do
        output, errors = capture_io { @obj.write '' } 
        paths = output.split("\n")
        assert_equal File.join(@site.dest, 'albums/gallery/index.html'), paths[0]
        assert_equal File.join(@site.dest, 'albums/gallery/2/index.html'), paths[1]
        assert_equal File.join(@site.dest, 'albums/gallery/3/index.html'), paths[2]
      end
    end
  end
end
