require 'test_helper'
require 'pathname'
require 'tenji/writer/thumbs'

class TenjiWriterThumbsTest < Minitest::Test
  context "Tenji::Wrter::Thumbs" do
    setup do
      @file = Pathname.new 'test/data/_albums/gallery2/01-castle.jpg'
      @obj = Tenji::Gallery::Image.new @file
    end

    context "has a class method #write that" do
      teardown do
        tmp = Pathname.new 'tmp'
        tmp.children.each { |c| c.delete }
      end

      should "write thumbnails" do
        input_name = @file.basename.sub_ext('')
        output_dir = Pathname.new 'tmp'
        output_basename = "#{input_name}-small.jpg"
        sizes = { 'small' => { 'x' => 400, 'y' => 400 } }
        Tenji::Writer::Thumbs.write @obj.thumbs, output_dir, sizes
        assert_equal (output_dir + output_basename).realpath.to_s,
                     @obj.thumbs['small']
      end
    end
  end
end
