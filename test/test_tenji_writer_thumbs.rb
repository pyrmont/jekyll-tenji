require 'test_helper'
require 'pathname'
require 'tenji/writer/thumbs'

class TenjiWriterThumbsTest < Minitest::Test
  context "Tenji::Writer::Thumbs" do
    setup do
      Tenji::Config.configure
      subdir = ('a'..'z').to_a.shuffle[0,8].join
      @temp_dir = Pathname.new('tmp/' + subdir)
      @temp_dir.mkpath
      @file = Pathname.new 'test/data/gallery2/01-castle.jpg'
      @obj = Tenji::Gallery::Image.new @file, Hash.new
    end

    teardown do
      Tenji::Config.reset
      @temp_dir.rmtree
    end

    context "has a class method #write that" do
      should "write thumbnails" do
        input_name = @file.basename.sub_ext('')
        output_basename = "#{input_name}-small.jpg"
        sizes = { 'small' => { 'x' => 400, 'y' => 400 } }
        Tenji::Writer::Thumbs.write @obj.thumbs, @file, @temp_dir, sizes
        assert_equal output_basename, @obj.thumbs['small']
      end
    end
  end
end
