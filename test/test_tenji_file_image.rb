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
    end

    teardown do
      @site = nil
    end

    context "has a method #initialize that" do
      should "initialize a File::Image object" do
        path = Pathname.new 'test/data/_albums/gallery1/photo1.jpg'
        obj = Tenji::File::Image.new @any, @site, @site.source, path.parent.to_s,
                                     path.basename.to_s
        assert_equal 'Tenji::File::Image', obj.class.name
      end
    end

    context "has a method #destination that" do
      setup do
        Tenji::Config.configure
        @path = Pathname.new 'test/data/_albums/gallery1/photo.jpg'
        @obj = Tenji::File::Image.new @any, @site, @site.source, @path.parent.to_s,
                                      @path.basename.to_s
      end

      teardown do
        Tenji::Config.reset
      end

      should "return the a directory path" do
        dest = File.join(@site.dest, @path.to_s).sub('_albums', 'albums')
        assert_equal dest, @obj.destination(@site.dest)
      end

      should "raise an error if the path is not a String" do
        assert_raises(Tenji::TypeError) { @obj.destination(nil) }
      end
    end
  end
end
