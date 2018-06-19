require 'test_helper'

class TenjiWriterThumbTest < Minitest::Test
  context "Tenji::Writer::Thumb" do
    setup do
      Tenji::Config.configure
      subdir = ('a'..'z').to_a.shuffle[0,8].join
      @temp_dir = Pathname.new('tmp/' + subdir)
      @temp_dir.mkpath
      @file = Pathname.new 'test/data/gallery2/01-castle.jpg'
      @sizes = { 'small' => { 'x' => 400, 'y' => 400 } }
      @obj = Tenji::Gallery::Image.new @file, @sizes
    end

    teardown do
      Tenji::Config.reset
      @temp_dir.rmtree
    end

    context "has a class method #write that" do
      should "write thumbnails" do
        Tenji::Writer::Thumb.write @obj.thumbs, @file, @temp_dir, @sizes
        input_name = @file.basename.sub_ext('')
        output_basename = "#{input_name}-small.jpg"
        output_file = Pathname.new(@temp_dir) + output_basename
        assert output_file.exist?
      end
    end
  end
end
