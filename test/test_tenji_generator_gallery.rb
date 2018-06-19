require 'test_helper'

class TenjiGeneratorGalleryTest < Minitest::Test
  context "Tenji::Generator::Gallery" do
    setup do
      Tenji::Config.configure
      @site = TestSite.site source: 'test/data', dest: 'tmp'
      path = Pathname.new 'test/data/gallery2'
      @gallery = Tenji::Gallery.new dir: path
    end

    teardown do
      Tenji::Config.reset
      @site = nil
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
      should "add to an array of Page objects" do
        base = Pathname.new @site.source
        prefix_path = Pathname.new 'gallery2'
        generator = Tenji::Generator::Gallery.new @gallery, @site, base,
                                                  prefix_path
        pages = Array.new
        generator.generate_index pages
        assert_equal [ 'Tenji::Page::Gallery' ],
                     pages.map { |p| p.class.name }.uniq
      end
    end
  end
end
