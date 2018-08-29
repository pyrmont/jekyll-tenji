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

  describe "#base" do
    it "returns the base of a path with no extension as a string" do
      assert_equal 'gallery', @obj.base
    end

    it "returns the base of a path with an extension as a string" do
      obj = Tenji::Path.new 'foo/bar.ext'
      assert 'bar', obj.base
    end
  end

  describe "#files" do
    it "returns an array of Paths that are files" do
      obj = Tenji::Path.new 'test/data/_albums/gallery'
      assert_equal Array.new(3, Tenji::Path), obj.files.map { |o| o.class }
    end
  end
end
