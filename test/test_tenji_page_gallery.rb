require 'test_helper'

class TenjiPageGalleryTest < Minitest::Test
  context "Tenji::Page::Gallery" do
    setup do
      Tenji::Config.configure
      gallery_dir = Pathname.new 'test/data/gallery1'
      @gallery = Tenji::Gallery.new gallery_dir, AnyType.new
      @site = TestSite.site source: 'test/data', dest: 'tmp'
      @base = @site.source
      @dir = gallery_dir.to_s
      @name = 'index.html'
      @gallery_name = 'gallery1'
    end

    teardown do
      Tenji::Config.reset
    end

    context "has a method #initialize that" do
      should "return an object" do
        obj = Tenji::Page::Gallery.new @gallery, @site, @base, @dir, @name, @gallery_name
        assert_equal 'Tenji::Page::Gallery', obj.class.name
      end

      should "raise an error with invalid arguments" do
        pg = Tenji::Page::Gallery
        assert_raises(Tenji::TypeError) { pg.new nil, @site, @base, @dir, @name, @gallery_name }
        assert_raises(Tenji::TypeError) { pg.new @gallery,  nil, @base, @dir, @name, @gallery_name }
        assert_raises(Tenji::TypeError) { pg.new @gallery, @site, nil, @dir, @name, @gallery_name }
        assert_raises(Tenji::TypeError) { pg.new @gallery, @site, @base, nil, @name, @gallery_name }
        assert_raises(Tenji::TypeError) { pg.new @gallery, @site, @base, @dir, nil, @gallery_name }
        assert_raises(Tenji::TypeError) { pg.new @gallery, @site, @base, @dir, @name, nil }
      end
    end

    context "has a method #path that" do
      setup do
        Tenji::Config.configure
      end

      teardown do
        Tenji::Config.reset
      end

      should "return a directory path" do
        obj = Tenji::Page::Gallery.new @gallery, @site, @base, @dir, @name, @gallery_name
        assert_equal '_albums/gallery1/index.html', obj.path
      end
    end
  end
end
