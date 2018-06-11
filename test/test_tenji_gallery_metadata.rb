require 'test_helper'
require 'pathname'
require 'tenji/gallery/metadata'

class TenjiGalleryMetadataTest < Minitest::Test
  context "Tenji::Gallery::Metadata" do
    context "has an initializer that" do
      should "return a default object when no YAML file exists" do
        file = Pathname.new 'test/data/_albums/gallery1/_gallery.yml'
        obj = Tenji::Gallery::Metadata.new file
        assert_equal 'Tenji::Gallery::Metadata', obj.class.name
        assert_equal 'gallery1', obj.name
        assert_equal '', obj.description
        assert_equal '', obj.period
        assert_equal false, obj.singles
        assert_equal 25, obj.paginate
      end

      should "return a custom object when a YAML file exists" do
        file = Pathname.new 'test/data/_albums/gallery2/_gallery.yml'
        obj = Tenji::Gallery::Metadata.new file
        assert_equal 'Tenji::Gallery::Metadata', obj.class.name
        assert_equal 'Test Gallery', obj.name
        assert_equal 'An example of a gallery.', obj.description
        assert_equal '1 January 2018 - 5 January 2018', obj.period
        assert_equal true, obj.singles
        assert_equal 15, obj.paginate
      end
    end
  end
end
