require 'test_helper'

describe Tenji::Path do
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
    before do
      @obj = Tenji::Path.new('galleries/a/gallery')
    end

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
      obj = Tenji::Path.new('galleries/a/gallery')
      assert_equal 'gallery', obj.base
    end

    it "returns the base of a path with an extension as a string" do
      obj = Tenji::Path.new 'foo/bar.ext'
      assert 'bar', obj.base
    end
  end

  describe "#files" do
    it "returns an array of Paths that are files in self" do
      obj = Tenji::Path.new 'test/data/_albums/gallery'
      assert_equal Array.new(3, Tenji::Path), obj.files.map { |o| o.class }
    end
  end

  describe "#image?" do
    it "returns true when it is an image" do
      obj = Tenji::Path.new 'foo.jpg'
      assert obj.image?
    end

    it "returns false when it is not an image" do
      obj = Tenji::Path.new 'foo.txt'
      refute obj.image?
    end

    it "returns false when it has no extension" do
      obj = Tenji::Path.new 'galleries/a/gallery'
      refute obj.image?
    end
  end

  describe "#index" do
    it "returns a Tenji::Path of an index file within itself" do
      obj = Tenji::Path.new 'test/data/_albums/gallery' 
      assert_equal 'test/data/_albums/gallery/index.md', obj.index.to_s
    end

    it "returns nil if there is no index file within itself" do
      obj = Tenji::Path.new 'test/data/_albums'
      assert_nil obj.index
    end
  end

  describe "#index?" do
    it "returns true if it represents an index" do
      obj = Tenji::Path.new 'index.md'
      assert obj.index?
    end

    it "returns false if it doesn't represent an index" do
      obj = Tenji::Path.new 'foo.md'
      refute obj.index?
    end
  end

  describe "#name" do
    it "returns the basename of a Tenji::Path object as a string" do
      obj = Tenji::Path.new 'a/path/to/a/file.html'
      assert_equal 'file.html', obj.name
    end
  end

  describe "#page?" do
    it "returns true if it represents a page" do
      obj = Tenji::Path.new 'foo.md'
      assert obj.page?
    end

    it "returns false if it doesn't represent a page" do
      obj = Tenji::Path.new 'foo'
      refute obj.page?
    end
  end

  describe "#subdirectories" do
    it "returns an array of Tenji::Path objects that represent directories in itself" do
      obj = Tenji::Path.new 'test/data/_albums'
      assert_equal [ Tenji::Path ], obj.subdirectories.map { |o| o.class }
    end
  end
end
