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

    describe "#deep_merge" do
      it "returns a merged hash where the provided argument has no common keys" do 
        obj = { a: 1, b: 2 }
        res = obj.deep_merge Hash[ c: 3 ]
        assert_equal Hash[ a: 1, b: 2, c: 3 ], res 
      end

      it "returns a merged hash where the provided argument has common keys" do
        obj = { a: 1, b: 2 }
        res = obj.deep_merge Hash[ b: 3 ]
        assert_equal Hash[ a: 1, b: 3 ], res
      end

      it "returns a merged hash where the provided argument has common keys that have hash values" do
        obj = { a: 1, b: { c: 3 } }
        res = obj.deep_merge Hash[ b: { d: 4 } ]
        assert_equal Hash[ a: 1, b: { c: 3, d: 4 } ], res
      end

      it "returns a merged hash where the provided argument has common keys that are nested" do
        obj = { a: 1, b: { c: 3 } }
        res = obj.deep_merge Hash[ b: { c: 4 } ]
        assert_equal Hash[ a: 1, b: { c: 4 } ], res
      end
    end
  end

  describe String do
    describe "#append_to_base" do
      it "inserts the argument before the final full stop" do
        obj = 'foo.bar'
        assert_equal 'foo2.bar', obj.append_to_base('2')
      end

      it "inserts the argument at the end of the itself if no full stop" do
        obj = 'foobar'
        assert_equal 'foobar2', obj.append_to_base('2')
      end
    end
  end
end
