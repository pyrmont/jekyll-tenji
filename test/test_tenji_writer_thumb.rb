require 'test_helper'

class TenjiWriterThumbTest < Minitest::Test
  context "Tenji::Writer::Thumb" do
    setup do
      Tenji::Config.configure
      subdir = ('a'..'z').to_a.shuffle[0,8].join
      @temp_dir = Pathname.new('tmp/' + subdir)
      @temp_dir.mkpath
    end

    teardown do
      Tenji::Config.reset
      @temp_dir.rmtree
    end

    context "has a class method #write that" do
      setup do
        file = Pathname.new 'test/data/gallery2/01-castle.jpg'
        source = Tenji::Image.new file, Hash.new, AnyType.new 
        dimensions = { 'x' => 400, 'y' => 400 }
        @obj = Tenji::Thumb.new 'small', dimensions, source
        @input_file = file
        @output_file = @temp_dir + @obj.name
      end

      teardown do
        @output_file.delete if @output_file.exist?
      end

      should "write a thumbnail to disk if the source is newer" do
        Tenji::Writer::Thumb.write @obj, @input_file, @temp_dir
        assert @output_file.exist?
      end

      should "do nothing if the source is older" do
        @output_file.write 'Test File'
        mtime = @output_file.mtime
        Tenji::Writer::Thumb.write @obj, @input_file, @temp_dir
        assert_equal mtime, @output_file.mtime
      end

      should "raise an error if given invalid arguments" do
        wt = Tenji::Writer::Thumb
        assert_raises(StandardError) { wt.write nil, @input_file, @temp_dir }
        assert_raises(StandardError) { wt.write @obj, nil, @temp_dir }
        assert_raises(StandardError) { wt.write @obj, @input_file, nil }
      end
    end
  end
end
