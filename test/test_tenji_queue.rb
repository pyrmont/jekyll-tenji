require 'test_helper'

describe Tenji::Queue do
  describe "#initialize" do
    it "instantiates a Tenji::Queue object using the default values" do
      obj = Tenji::Queue.new
      assert_equal Tenji::Queue, obj.class
      assert_nil obj.list_page
      assert_equal Hash.new, obj.gallery_pages
      assert_equal Hash.new, obj.image_files
      assert_equal Hash.new, obj.image_pages
      assert_equal Hash.new, obj.thumb_files
      assert_equal Hash.new, obj.cover_files
    end

    it "instantiates a Tenji::Queue object with prepared values" do
      args = [ 'foo', { 'foo' => 'bar' }, { 'foo' => [ 'bar' ] }, { 'foo' => { 'foo' => 'bar' } }, { 'foo' => { 'foo' => { 'foo' => 'bar' } } }, { 'foo' => 'bar' } ]
      obj = Tenji::Queue.new args

      assert_equal Tenji::Queue, obj.class

      assert_equal 'foo', obj.list_page
      assert_equal 'bar', obj.gallery_pages['foo']
      assert_equal 'bar', obj.image_files['foo'].first
      assert_equal 'bar', obj.image_pages['foo']['foo']
      assert_equal 'bar', obj.thumb_files['foo']['foo']['foo']
      assert_equal 'bar', obj.cover_files['foo']

      assert_nil obj.gallery_pages['bar']
      assert_equal Array.new, obj.image_files['bar']
      assert_equal Hash.new, obj.image_pages['bar']
      assert_equal Hash.new, obj.thumb_files['bar']['bar']
      assert_nil obj.cover_files['bar']
    end
  end

  describe "#to_a" do
    it "returns an array of the default values" do
      args = [ nil, Hash.new, Hash.new, Hash.new, Hash.new, Hash.new ]
      obj = Tenji::Queue.new
      assert_equal args, obj.to_a
    end

    it "returns an array of the values used when initialising it" do
      args = [ 'foo', { 'foo' => 'bar' }, { 'foo' => [ 'bar' ] }, { 'foo' => { 'foo' => 'bar' } }, { 'foo' => { 'foo' => { 'foo' => 'bar' } } }, { 'foo' => 'bar' } ]
      obj = Tenji::Queue.new args
      assert_equal args, obj.to_a
    end
  end
end
