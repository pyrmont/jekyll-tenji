require 'test_helper'
require 'jekyll'
require 'pathname'
require 'tenji/gallery'
require 'tenji/generator/gallery'

class TenjiGeneratorGalleryTest < Minitest::Test
  context "Tenji::Generator::Gallery" do
    setup do
      Jekyll.logger.log_level = :error
      source_dir = Pathname.new('test/data').realpath.to_s
      dest_dir = Pathname.new('tmp').realpath.to_s
      config = Jekyll.configuration({ 'source' => source_dir,
                                      'destination' => dest_dir,
                                      'url' => 'http://localhost' })
      @site = Jekyll::Site.new config
      path = Pathname.new 'test/data/_albums/gallery2'
      @gallery = Tenji::Gallery.new dir: path
    end

    context "has a method #initialize that" do
      should "return an object" do
        base = Pathname.new @site.source
        prefix_path = Pathname.new 'gallery2'
        obj = Tenji::Generator::Gallery.new @gallery, @site, base,
                                            prefix_path
        assert_equal 'Tenji::Generator::Gallery', obj.class.name
      end
    end

    context "has a method #generate_index that" do
      should "return an array of Page objects" do
        base = Pathname.new @site.source
        prefix_path = Pathname.new 'gallery2'
        generator = Tenji::Generator::Gallery.new @gallery, @site, base,
                                                  prefix_path
        obj = generator.generate_index
        assert_equal [ 'Tenji::Page::Gallery' ],
                     obj.map { |o| o.class.name }.uniq
      end
    end
  end
end
