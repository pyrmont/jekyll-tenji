require 'test_helper'

class TenjiPageGalleryTest < Minitest::Test
  context "Tenji::Page::Gallery" do
    setup do
      Tenji::Config.configure
      gallery_dir = Pathname.new 'test/data/gallery1'
      @gallery = Tenji::Gallery.new gallery_dir, AnyType.new
      @site = TestSite.site source: 'test/data', dest: 'tmp'
      @base = @site.source
      @output_dirname = gallery_dir.to_s
      @name = 'index.html'
      @input_dirname = gallery_dir.to_s
    end

    teardown do
      Tenji::Config.reset
    end

    context "has a method #initialize that" do
      should "return an object" do
        obj = Tenji::Page::Gallery.new @gallery, @site, @base, @output_dirname, @name, @input_dirname
        assert_equal 'Tenji::Page::Gallery', obj.class.name
      end

      should "raise an error with invalid arguments" do
        pg = Tenji::Page::Gallery
        assert_raises(Tenji::TypeError) { pg.new nil, @site, @base, @output_dirname, @name, @input_dirname }
        assert_raises(Tenji::TypeError) { pg.new @gallery,  nil, @base, @output_dirname, @name, @input_dirname }
        assert_raises(Tenji::TypeError) { pg.new @gallery, @site, nil, @output_dirname, @name, @input_dirname }
        assert_raises(Tenji::TypeError) { pg.new @gallery, @site, @base, nil, @name, @input_dirname }
        assert_raises(Tenji::TypeError) { pg.new @gallery, @site, @base, @output_dirname, nil, @input_dirname }
        assert_raises(Tenji::TypeError) { pg.new @gallery, @site, @base, @output_dirname, @name, nil }
      end
    end

    context "has a method #path that" do
      setup do
        Tenji::Config.configure
      end

      teardown do
        Tenji::Config.reset
      end

      should "return a file path" do
        output_path = 'albums/gallery1'
        obj = Tenji::Page::Gallery.new @gallery, @site, @base, @output_dirname, @name, @input_dirname
        assert_equal 'test/data/gallery1/index.html', obj.path
      end
    end
  end
end
