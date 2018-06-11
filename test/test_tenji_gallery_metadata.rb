require 'test_helper'
require 'pathname'
require 'tenji/gallery/metadata'

class TenjiGalleryMetadataTest < Minitest::Test
  context "Tenji::Gallery::Metadata" do
    context "has an initializer that" do
      should "return a Tenji::Gallery::Metadata object" do
        file = Pathname.new 'data/_albums/gallery1/_gallery.yml'
        obj = Tenji::Gallery::Metadata.new file
        assert_equal 'Tenji::Gallery::Metadata', obj.class.name
        assert_equal 'gallery1', obj.name
        assert_equal '', obj.description
        assert_equal '', obj.period
        assert_equal false, obj.singles
        assert_equal 25, obj.paginate
      end
    end
  end
end
