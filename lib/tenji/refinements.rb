# frozen_string_literal: true

module Tenji
  module Refinements
    refine Hash do
      def deep_copy()
        res = Hash.new &(self.default_proc)
        self.each do |k,v|
          value = v.is_a?(Hash) ? v.deep_copy : v.dup
          res[k] = value
        end
        res
      end

      def deep_merge(h)
        res = self.merge h
        self.each do |k,v|
          if h.key?(k) && h[k].is_a?(Hash)
            res[k] = self[k].deep_merge h[k]
          end
        end
        res
      end
    end

    refine String do
      def append_to_base(str)
        pos = self.rindex('.') || self.length
        infix pos, str
      end

      def infix(pos, str)
        raise RangeError if pos.abs > length
        self[0...pos] + str + self[pos..-1]
      end
    end
  end
end
