require 'test_helper'

describe Tenji::Writer do
  before do
    @temp_dir = Pathname.new('tmp') + ('a'..'z').to_a.shuffle[0,8].join
    @temp_dir.mkpath
    @obj = Tenji::Writer.new
  end

  after do
    @temp_dir.rmtree
  end

  describe "#write_thumb" do
    before do
      @input_path = Pathname.new('test') + 'data' + '_albums' + 'gallery' + '01-castle.jpg'
      @output_path = @temp_dir + 'output.jpg'
      @constraints = { 'x' => 400, 'y' => 400 }
    end

    after do
      @output_path.delete if @output_path.exist?
    end
    
    it "writes an image to the output directory using the fill function" do
      @obj.write_thumb @input_path.to_s, @output_path.to_s, @constraints, 'fill'
      output = Magick::Image.ping(@output_path.to_s).first
      assert_equal 400, output.columns
      assert_equal 400, output.rows
    end

    it "writes an image to the output directory using the fit function" do
      @obj.write_thumb @input_path.to_s, @output_path.to_s, @constraints, 'fit'
      output = Magick::Image.ping(@output_path.to_s).first
      assert_equal 400, output.columns
      refute_equal 400, output.rows
    end

    it "writes an image to the output directory using the fit function and only the x-constraint" do
      @obj.write_thumb @input_path.to_s, @output_path.to_s, { 'x' => 400 }, 'fit'
      output = Magick::Image.ping(@output_path.to_s).first
      assert_equal 400, output.columns
      refute_equal 400, output.rows
    end

    it "writes an image to the output directory using the fit function and only the y-constraint" do
      @obj.write_thumb @input_path.to_s, @output_path.to_s, { 'y' => 400 }, 'fit'
      output = Magick::Image.ping(@output_path.to_s).first
      refute_equal 400, output.columns
      assert_equal 400, output.rows
    end

    it "does not write an image if there is a newer one on disk" do
      @obj.write_thumb @input_path.to_s, @output_path.to_s, @constraints, 'fit'
      first_time = File.mtime(@output_path)
      @obj.write_thumb @input_path.to_s, @output_path.to_s, @constraints, 'fit'
      second_time = File.mtime(@output_path)
      assert_equal first_time, second_time
    end

    it "raises an error when the constraints are invalid for the fill function" do
      assert_raises(Tenji::Writer::ResizeConstraintError) do
        @obj.write_thumb @input_path.to_s, @output_path.to_s, { 'x' => 100 }, 'fill'
      end
    end

    it "raises an error when the constraints are invalid for the fit function" do
      assert_raises(Tenji::Writer::ResizeConstraintError) do
        @obj.write_thumb @input_path.to_s, @output_path.to_s, Hash.new, 'fit'
      end
    end

    it "raises an error when the resize function is unknown" do
      assert_raises(Tenji::Writer::ResizeInvalidFunctionError) do
        @obj.write_thumb @input_path.to_s, @output_path.to_s, @constraints, 'unknown'
      end
    end
  end
end

