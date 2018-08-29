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
end
