require 'test_helper'

describe Tenji::Pageable do
  before do
    @obj = Object.new
    @obj.singleton_class.include Tenji::Pageable
  end

  describe "#items_per_page" do
    it "returns the number of items per page" do
      assert_nil @obj.items_per_page

      @obj.instance_variable_set(:@__items_per_page__, 42)

      assert_equal 42, @obj.items_per_page
    end
  end
end
