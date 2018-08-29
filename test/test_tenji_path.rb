require 'test_helper'

describe Tenji::Path do
  before do
    @obj = Tenji::Path.new('galleries/a/gallery')
  end

  describe "#initialize" do
    it "instantiates a Tenji::Path object with a String object" do
      path = 'a/path/to/somewhere'
      obj = Tenji::Path.new path
      assert_equal Tenji::Path, obj.class
      assert_equal path, obj.to_s
    end

    it "instantiates a Tenji::Path object with another Tenji::Path object" do
      path = 'foo'
      seed = Tenji::Path.new path
      obj = Tenji::Path.new seed
      assert_equal Tenji::Path, obj.class
      assert_equal path, obj.to_s
    end
  end

  describe "#+" do
    it "returns a Tenji::Path object with a concatenated path if the operand is a Tenji::Path object" do
      other = Tenji::Path.new 'foo'
      res = @obj + other
      assert_equal res.to_s, File.join(@obj.to_s, other.to_s)
    end

    it "returns a Tenji::Path object with a concatenated path if the operand is a String object" do
      other = 'foo'
      res = @obj + other
      assert_equal res.to_s, File.join(@obj.to_s, other.to_s)
    end

    it "returns a Tenji::Path object with the same path if the operand is an empty string" do
      other = ''
      res = @obj + ''
      assert_equal res.to_s, @obj.to_s
    end
  end
end
