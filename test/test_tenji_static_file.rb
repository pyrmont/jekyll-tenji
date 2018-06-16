require 'test_helper'
require 'jekyll'
require 'pathname'
require 'tenji/static_file'

class TenjiStaticFileTest < Minitest::Test
  context "Tenji::StaticFile" do
    context "has a method #initialize that" do
      setup do
        Jekyll.logger.log_level = :error
        source_dir = Pathname.new('test/data').realpath.to_s
        dest_dir = Pathname.new('tmp').realpath.to_s
        config = Jekyll.configuration({ 'source' => source_dir,
                                        'destination' => dest_dir,
                                        'url' => 'http://localhost' })
        @site = Jekyll::Site.new config
      end

      should "return an object" do
        path = Pathname.new 'test/data/_albums/gallery1/photo1.jpg'
        obj = Tenji::StaticFile.new @site, @site.source, path.parent.to_s,
                                    path.basename.to_s
        assert_equal 'Tenji::StaticFile', obj.class.name
      end
    end
  end
end
