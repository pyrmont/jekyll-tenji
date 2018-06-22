require 'test_helper'

class TenjiFileImageTest < Minitest::Test
  context "Tenji::File::Image" do
    setup do
      Jekyll.logger.log_level = :error
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
        obj = Tenji::File::Image.new @site, @site.source, path.parent.to_s,
                                    path.basename.to_s
        assert_equal 'Tenji::File::Image', obj.class.name
      end
    end

    context "has a method #destination that" do
      should "return the a directory path" do
        Tenji::Config.configure
        path = Pathname.new 'test/data/_albums/gallery1/photo.jpg'
        obj = Tenji::File::Image.new @site, @site.source, path.parent.to_s,
                                     path.basename.to_s
        dest = File.join(@site.dest, path.to_s).sub('_albums', 'albums')
        assert_equal dest, obj.destination(@site.dest)
        Tenji::Config.reset
      end
    end
  end
end
