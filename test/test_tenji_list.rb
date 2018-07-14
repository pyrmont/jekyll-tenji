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
        obj = Tenji::List.new dir
        assert_equal 'Tenji::List', obj.class.name
        assert_equal '_albums', obj.dirname
        assert_equal [ 'Tenji::Gallery' ], obj.galleries.map { |g| g.class.name }
        assert_equal 'Hash', obj.metadata.class.name
        assert_equal '', obj.text
      end

      should "raise an error if the file doesn't exist" do
        dir = Pathname.new 'not/a/real/directory'
        assert_raises(Tenji::NotFoundError) { Tenji::List.new dir }
      end
    end
  end
end
