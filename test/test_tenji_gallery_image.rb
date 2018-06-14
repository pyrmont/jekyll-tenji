require 'test_helper'
require 'pathname'
require 'tenji/gallery/image'

class TenjiGalleryImageTest < Minitest::Test
  context "Tenji::Gallery::Image" do
    context "has a method #initialize that" do
      should "return an object if the file exists" do
        file = Pathname.new 'test/data/_albums/gallery1/photo1.jpg'
        obj = Tenji::Gallery::Image.new file
        assert_equal 'Tenji::Gallery::Image', obj.class.name
        assert_equal 'photo1.jpg', obj.name
      end

      should "raise an error if the file doesn't exist" do
        file = Pathname.new 'not/a/real/file'
        assert_raises(StandardError) { Tenji::Gallery::Image.new file }
      end
    end
  end

  context "Tenji::Gallery::Image::Thumb" do
    setup do
      @file = Pathname.new 'test/data/_albums/gallery2/01-castle.jpg'
      @obj = Tenji::Gallery::Image::Thumb.new @file
    end

    context "has a method #initialize that" do
      should "return an object if passed a path" do
        assert_equal 'Tenji::Gallery::Image::Thumb', @obj.class.name
        assert_equal Hash.new, @obj.files
        assert_equal @file, @obj.source
      end
    end

    context "has a method #generate that" do
      teardown do
        tmp = Pathname.new 'tmp'
        tmp.children.each { |c| c.delete }
      end
      should "generate thumbnails" do
        input_name = @file.basename.sub_ext('')
        output_dir = Pathname.new 'tmp'
        output_basename = "#{input_name}-small.jpg"
        sizes = { 'small' => { 'x' => 400, 'y' => 400 } }
        @obj.generate output_dir, sizes
        assert_equal (output_dir + output_basename).realpath.to_s, @obj['small']
      end
    end
  end
end
