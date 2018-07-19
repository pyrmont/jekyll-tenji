require 'test_helper'

class TenjiFileImageTest < Minitest::Test
  context "Tenji::File::Image" do
    setup do
      @any = AnyType.new
      source_dir = Pathname.new('test/data').realpath.to_s
      dest_dir = Pathname.new('tmp').realpath.to_s
      config = Jekyll.configuration({ 'source' => source_dir,
                                      'destination' => dest_dir,
                                      'url' => 'http://localhost' })
      @site = Jekyll::Site.new config
      @obj = Tenji::File::Image.new @site, @site.source, 'albums/gallery1',
                                    'photo1.jpg', 'gallery1'
    end

    teardown do
      @site = nil
    end

    context "has a method #initialize that" do
      should "initialize a File::Image object" do
        assert_equal 'Tenji::File::Image', @obj.class.name
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
        assert_equal @site.source + '/_albums/gallery1/photo1.jpg', @obj.path
      end
    end
  end
end
