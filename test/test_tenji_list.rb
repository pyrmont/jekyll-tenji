require 'test_helper'

class TenjiListTest < Minitest::Test
  context "Tenji::List" do
    setup do
      Tenji::Config.configure
    end

    teardown do
      Tenji::Config.reset
    end

    context "has a method #initialize that" do
      should "initialize a List object" do
        dir = Pathname.new 'test/data/_albums/'
        obj = Tenji::List.new dir, AnyType.new
        assert_equal Tenji::List, obj.class
        assert_equal '_albums', obj.dirname
        assert_equal Hash, obj.metadata.class
        assert_equal '', obj.text
      end

      should "raise an error if the file doesn't exist" do
        dir = Pathname.new 'not/a/real/directory'
        assert_raises(Tenji::NotFoundError) { Tenji::List.new dir, AnyType.new }
      end
    end

    context "has a method #to_liquid that" do
      should "return a Hash object with certain keys set" do
        dir = Pathname.new 'test/data/_albums/'
        list = Tenji::List.new dir, AnyType.new(methods: { 'foo' => 'bar' })
        obj = list.to_liquid
        assert_equal 'bar', obj['galleries'].foo
      end
    end
  end
end
