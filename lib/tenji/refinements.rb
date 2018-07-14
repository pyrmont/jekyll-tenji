# frozen_string_literal: true

module Tenji
  module Refinements
    refine Object do
      def is_a!(type)
        return if self.is_a? type
        val = self.to_s.empty? ? 'NIL' : self
        msg = "Value #{val} is of type #{self.class.name}, expected #{type}"
        raise Tenji::TypeError.new msg
      end
    end

    refine Pathname do
      def append_to_base(str)
        ext = self.extname
        base = self.sub_ext('').to_s
        Pathname.new(base + str + ext)
      end

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
