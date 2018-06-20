require 'test_helper'

class TenjiGeneratorListTest < Minitest::Test
  context "Tenji::Generator::List" do
    setup do
      Tenji::Config.configure
      @site = TestSite.site source: 'test/data', dest: 'tmp'
      path = Pathname.new 'test/data/gallery2'
      @galleries = [ Tenji::Gallery.new(dir: path) ]
    end

    teardown do
      Tenji::Config.reset
      @site = nil
    end

    context "has a method #initialize that" do
      should "return an object" do
        base = Pathname.new @site.source
        prefix_path = Pathname.new ''
        obj = Tenji::Generator::List.new @galleries, @site, base,
                                            prefix_path
        assert_equal 'Tenji::Generator::List', obj.class.name
      end
    end

    context "has a method #generate_index that" do
      should "add to an array of Page objects" do
        base = Pathname.new @site.source
        prefix_path = Pathname.new ''
        generator = Tenji::Generator::List.new @galleries, @site, base,
                                                  prefix_path
        pages = Array.new
        generator.generate_index pages
        assert_equal [ 'Tenji::Page::List' ],
                     pages.map { |p| p.class.name }.uniq
      end
    end
  end
end
