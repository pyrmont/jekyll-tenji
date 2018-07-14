require 'test_helper'

class TenjiPageGalleryTest < Minitest::Test
  context "Tenji::Page::Gallery" do
    setup do
      Tenji::Config.configure
      dir = Pathname.new 'test/data/gallery1'
      @gallery = Tenji::Gallery.new dir, AnyType.new
      @site = TestSite.site source: 'test/data', dest: 'tmp'
      @base = @site.source
      @prefix_path = dir.to_s
      @name = 'index.html'
    end

    teardown do
      Tenji::Config.reset
    end

    context "has a method #initialize that" do
      should "return an object" do
        obj = Tenji::Page::Gallery.new @gallery, @site, @base, @prefix_path, @name
        assert_equal 'Tenji::Page::Gallery', obj.class.name
      end

      should "raise an error with invalid arguments" do
        pg = Tenji::Page::Gallery
        assert_raises(Tenji::TypeError) { pg.new nil, @site, @base, @prefix_path, @name }
        assert_raises(Tenji::TypeError) { pg.new @gallery,  nil, @base, @prefix_path, @name }
        assert_raises(Tenji::TypeError) { pg.new @gallery, @site, nil, @prefix_path, @name }
        assert_raises(Tenji::TypeError) { pg.new @gallery, @site, @base, nil, @name }
        assert_raises(Tenji::TypeError) { pg.new @gallery, @site, @base, @prefix_path, nil }
      end
    end

    context "has a method #destination that" do
      setup do
        @fake_path = 'not/a/real/path/_albums/gallery'
        @obj = Tenji::Page::Gallery.new @gallery, @site, @base, @fake_path, @name
      end

      should "return a modified path" do
        local_path = 'tmp/not/a/real/path/albums/gallery/index.html'
        dest_expected = Pathname.new(local_path).expand_path.to_s
        dest_actual = @obj.destination @site.dest
        assert_equal dest_expected, dest_actual
      end

      should "raise an error for an invalid argument" do
        assert_raises(Tenji::TypeError) { @obj.destination nil }
      end
    end
  end
end
