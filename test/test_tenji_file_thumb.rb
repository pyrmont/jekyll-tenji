require 'test_helper'

class TenjiFileThumbTest < Minitest::Test
  context "Tenji::File::Thumb" do
    setup do
      Jekyll.logger.log_level = :error
      source_dir = Pathname.new('test/data/site').realpath.to_s
      dest_dir = Pathname.new('tmp').realpath.to_s
      config = Jekyll.configuration({ 'source' => source_dir,
                                      'destination' => dest_dir,
                                      'url' => 'http://localhost' })
      @site = Jekyll::Site.new config
      @obj = Tenji::File::Thumb.new @site, @site.source, 'albums/gallery1/thumbs',
                                    'photo1-small.jpg', 'gallery1'
    end

    teardown do
      @site = nil
    end

    context "has a method #initialize that" do
      should "initialize a File::Thumb object" do
        assert_equal 'Tenji::File::Thumb', @obj.class.name
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
        assert_equal @site.source + '/_thumbs/gallery1/photo1-small.jpg', @obj.path
      end
    end
  end
end
