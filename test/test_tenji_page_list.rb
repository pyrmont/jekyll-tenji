require 'test_helper'

class TenjiPageListTest < Minitest::Test
  context "Tenji::Page::List" do
    setup do
      Tenji::Config.configure
    end

    teardown do
      Tenji::Config.reset
    end

    context "has a method #initialize that" do
      should "return an object" do
        dir = Pathname.new 'test/data/gallery1'
        galleries = [ Tenji::Gallery.new(dir: dir) ]
        site = TestSite.site source: 'test/data', dest: 'tmp'
        base = site.source
        prefix_path = ''
        obj = Tenji::Page::List.new galleries, site, base, prefix_path, 'index.html' 
        assert_equal 'Tenji::Page::List', obj.class.name
      end
    end
  end
end