require 'test_helper'

class TenjiFileThumbTest < Minitest::Test
  context "Tenji::File::Thumb" do
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
      should "initialize a File::Thumb object" do
        path = Pathname.new 'test/data/_albums/gallery1/photo1.jpg'
        obj = Tenji::File::Thumb.new @site, @site.source, path.parent.to_s,
                                    path.basename.to_s
        assert_equal 'Tenji::File::Thumb', obj.class.name
      end
    end

    context "has a method #destination that" do
      setup do
        Tenji::Config.configure
        @path = Pathname.new 'test/data/_thumbs/gallery1/photo-small.jpg'
        @obj = Tenji::File::Thumb.new @site, @site.source, @path.parent.to_s,
                                      @path.basename.to_s
      end

      teardown do
        Tenji::Config.reset
      end

      should "return the a directory path" do
        temp = Pathname.new(@site.dest) + @path.sub('_thumbs', 'albums')
        dest = temp.parent + 'thumbs' + temp.basename
        assert_equal dest.to_s, @obj.destination(@site.dest)
      end

      should "raise an error if the path is not a String" do
        assert_raises(StandardError) { @obj.destination(nil) }
      end
    end
  end
end
