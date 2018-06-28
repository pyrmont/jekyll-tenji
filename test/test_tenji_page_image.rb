require 'test_helper'

class TenjiPageImageTest < Minitest::Test
  context "Tenji::Image::Gallery" do
    setup do
      Tenji::Config.configure
      dir = Pathname.new 'test/data/gallery1'
      @image = Tenji::Image.new dir, Hash.new, AnyType.new
      @site = TestSite.site source: 'test/data', dest: 'tmp'
      @base = @site.source
      @prefix_path = dir.to_s
      @name = 'photo1.jpg'
    end

    teardown do
      Tenji::Config.reset
    end

    context "has a method #initialize that" do
      should "initialise a Page::Image object" do
        obj = Tenji::Page::Image.new @image, @site, @base, @prefix_path, @name 
        assert_equal 'Tenji::Page::Image', obj.class.name
      end

      should "raise an error with invalid arguments" do
        pi = Tenji::Page::Image
        assert_raises(StandardError) { pi.new nil, @site, @base, @prefix_path, @name }
        assert_raises(StandardError) { pi.new @image,  nil, @base, @prefix_path, @name }
        assert_raises(StandardError) { pi.new @image, @site, nil, @prefix_path, @name }
        assert_raises(StandardError) { pi.new @image, @site, @base, nil, @name }
        assert_raises(StandardError) { pi.new @image, @site, @base, @prefix_path, nil }
      end
    end
  
    context "has a method #destination that" do
      setup do
        @fake_path = 'not/a/real/path/_albums/gallery'
        @obj = Tenji::Page::Image.new @image, @site, @base, @fake_path, @name
      end

      should "return a modified path" do
        local_path = 'tmp/not/a/real/path/albums/gallery/photo1.html'
        dest_expected = Pathname.new(local_path).expand_path.to_s
        dest_actual = @obj.destination @site.dest
        assert_equal dest_expected, dest_actual
      end

      should "raise an error for an invalid argument" do
        assert_raises(StandardError) { @obj.destination nil }
      end
    end
  end
end
