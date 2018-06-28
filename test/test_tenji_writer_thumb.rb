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
      @obj = Tenji::Image.new @file, @sizes, AnyType.new
    end

    teardown do
      Tenji::Config.reset
      @temp_dir.rmtree
    end

    context "has a class method #write that" do
      setup do
        @input_name = @file.basename.sub_ext('')
        @output_basename = "#{@input_name}-small.jpg"
        @output_file = Pathname.new(@temp_dir) + @output_basename
      end

      teardown do
        @output_file.delete if @output_file.exist?
      end

      should "write a thumbnail to disk if the source is newer" do
        Tenji::Writer::Thumb.write @obj.thumbs, @file, @temp_dir, @sizes
        assert @output_file.exist?
      end

      should "do nothing if the source is older" do
        @output_file.write 'Test File'
        mtime = @output_file.mtime
        Tenji::Writer::Thumb.write @obj.thumbs, @file, @temp_dir, @sizes
        assert_equal mtime, @output_file.mtime
      end

      should "raise an error if given invalid arguments" do
        wt = Tenji::Writer::Thumb
        assert_raises(StandardError) { wt.write nil, @file, @temp_dir, @sizes }
        assert_raises(StandardError) { wt.write @obj.thumbs, nil, @temp_dir, @sizes }
        assert_raises(StandardError) { wt.write @obj.thumbs, @file, nil, @sizes }
        assert_raises(StandardError) { wt.write @obj.thumbs, @file, @temp_dir, nil }
      end
    end
  end
end
