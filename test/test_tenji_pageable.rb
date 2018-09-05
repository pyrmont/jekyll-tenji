require 'test_helper'

describe Tenji::Pageable do
  before do
    site = Object.new
    @obj = Object.new
    @obj.define_singleton_method(:site) { site }
    @obj.singleton_class.include Tenji::Pageable
  end

  describe "#items_per_page" do
    it "returns the number of items per page" do
      assert_nil @obj.items_per_page

      @obj.instance_variable_set(:@__items_per_page__, 42)

      assert_equal 42, @obj.items_per_page
    end
  end

  describe "#paginate" do
    it "prepends a Tenji::Pageable::Page module and a Tenji::Pageable::Site module if the parameter is truthy" do
      assert_nil @obj.instance_variable_get(:@__items_per_page__)
      refute @obj.site.singleton_class.ancestors.include?(Tenji::Pageable::Site)
      refute @obj.singleton_class.ancestors.include?(Tenji::Pageable::Page)

      @obj.paginate 10

      assert 10, @obj.instance_variable_get(:@__items_per_page__)
      assert @obj.site.singleton_class.ancestors.include?(Tenji::Pageable::Site)
      assert @obj.singleton_class.ancestors.include?(Tenji::Pageable::Page)
    end

    it "prepends a Tenji::Pageable::Page module and a Tenji::Pageable::Site module if the parameter is falsey" do
      assert_nil @obj.instance_variable_get(:@__items_per_page__)
      refute @obj.site.singleton_class.ancestors.include?(Tenji::Pageable::Site)
      refute @obj.singleton_class.ancestors.include?(Tenji::Pageable::Page)

      @obj.paginate false

      assert_nil @obj.instance_variable_get(:@__items_per_page__)
      refute @obj.site.singleton_class.ancestors.include?(Tenji::Pageable::Site)
      refute @obj.singleton_class.ancestors.include?(Tenji::Pageable::Page)
    end
  end
end
