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

    refine Object do
      def is_a!(type)
        return if self.is_a? type
        val = self.to_s.empty? ? 'NIL' : self
        msg = "Value #{val} is type #{self.class.name}, expected #{type}"
        raise Tenji::TypeError.new msg
      end

      def is_maybe!(type)
        return if self.is_a?(type) || self.nil?
        val = self.to_s.empty? ? 'NIL' : self
        msg = "Value #{val} is type #{self.class.name}, expected #{type} or nil"
        raise Tenji::TypeError.new msg
      end
    end

    refine Pathname do
      def exist!()
        return if self.exist?
        msg = "#{self} does not exist"
        raise Tenji::NotFoundError, msg
      end

      def file!()
        return unless self.directory?
        msg = "#{self} is not a file"
        raise Tenji::NotAFileError, msg
      end

      def images()
        self.children.select do |c|
          c.extname == '.jpg'
        end
      end

      def subdirectories()
        self.children.select do |c|
          c.directory?
        end
      end
    end

    refine String do
      def append_to_base(str)
        pos = self.rindex('.') || self.length
        infix pos, str
      end

      def infix(pos, str)
        return nil if pos.abs > length
        self[0...pos] + str + self[pos..-1]
      end

      def sub_ext(str)
        pos = self.rindex('.') || self.length
        self[0...pos] + str
      end
    end
  end
end
