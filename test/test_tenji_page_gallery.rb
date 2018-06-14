require 'test_helper'
require 'tenji/gallery'
require 'tenji/page/gallery'

class TenjiPageGalleryTest < Minitest::Test
  context "Tenji::Page::Gallery" do
    context "has a method #initialize that" do
      should "return an object" do
        dir = Pathname.new 'test/data/_albums/gallery1'
        gallery = Tenji::Gallery.new dir: dir
        obj = Tenji::Page::Gallery.new '', '', '', gallery 
        assert_equal 'Tenji::Page::Gallery', obj.class.name
      end
    end
  end
end
