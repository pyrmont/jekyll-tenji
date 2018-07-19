require 'test_helper'

class TenjiPageImageTest < Minitest::Test
  context "Tenji::Image::Gallery" do
    setup do
      Tenji::Config.configure
      gallery_dir = Pathname.new 'test/data/gallery1'
      file = gallery_dir + 'photo1.jpg'
      @gallery = AnyType.new methods: { 'dirname' => gallery_dir.basename.to_s,
                                       'images' => Array.new }
      capture_io do
        @image = Tenji::Image.new file, Hash.new, @gallery
      end
      @site = TestSite.site source: 'test/data', dest: 'tmp'
      @base = @site.source
      @dir = gallery_dir.to_s
      @name = file.basename.to_s
    end

    teardown do
      Tenji::Config.reset
    end

    context "has a method #initialize that" do
      should "initialise a Page::Image object" do
        obj = Tenji::Page::Image.new @image, @site, @base, @dir, @name, @gallery.dirname
        assert_equal 'Tenji::Page::Image', obj.class.name
      end

      should "raise an error with invalid arguments" do
        pi = Tenji::Page::Image
        assert_raises(Tenji::TypeError) { pi.new nil, @site, @base, @dir, @name, @gallery.dirname }
        assert_raises(Tenji::TypeError) { pi.new @image, nil, @base, @dir, @name, @gallery.dirname }
        assert_raises(Tenji::TypeError) { pi.new @image, @site, nil, @dir, @name, @gallery.dirname }
        assert_raises(Tenji::TypeError) { pi.new @image, @site, @base, nil, @name, @gallery.dirname }
        assert_raises(Tenji::TypeError) { pi.new @image, @site, @base, @dir, nil, @gallery.dirname }
        assert_raises(Tenji::TypeError) { pi.new @image, @site, @base, @dir, @name, nil }
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
        fake_path = 'albums/gallery1'
        obj = Tenji::Page::Image.new @image, @site, @base, fake_path, @name, @gallery.dirname
        assert_equal '_albums/gallery1/photo1.html', obj.path
      end
    end
  end
end
