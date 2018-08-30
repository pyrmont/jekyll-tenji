require 'test_helper'

describe Tenji::Refinements do
  using Tenji::Refinements

  describe Hash do
    describe "#deep_copy" do
      it "returns a copy of an empty hash that is a separate object in memory" do
        obj = Hash.new
        res = obj.deep_copy
        assert_equal obj, res
        refute_equal obj.object_id, res.object_id
      end

      it "returns a copy of a non-empty hash that is a separate object with no shared references" do
        obj = { 'foo' => { 'bar' => Hash.new } }
        res = obj.deep_copy
        assert_equal obj, res
        refute_equal obj.object_id, res.object_id
        refute_equal obj['foo'].object_id, res['foo'].object_id
        refute_equal obj['foo']['bar'].object_id, res['foo']['bar'].object_id
      end

      it "returns a copy of a hash with a default proc" do
        obj = Hash.new { |h,k| h[k] = Array.new }
        res = obj.deep_copy
        assert_equal obj, res
        assert_equal obj.default_proc, res.default_proc
        refute_equal obj.object_id, res.object_id
      end
    end
  end
end
