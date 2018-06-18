require 'test_helper'
require 'pathname'
require 'tenji/gallery'
require 'tenji/page/gallery'

class TenjiPageGalleryTest < Minitest::Test
  context "Tenji::Page::Gallery" do
    context "has a method #initialize that" do
      should "return an object" do
        dir = Pathname.new 'test/data/gallery1'
        gallery = Tenji::Gallery.new dir: dir
        site = TestSite.site source: 'test/data', dest: 'tmp'
        base = Pathname.new site.source
        obj = Tenji::Page::Gallery.new gallery, site, base, dir, 'index.html' 
        assert_equal 'Tenji::Page::Gallery', obj.class.name
      end
    end
  end
end
