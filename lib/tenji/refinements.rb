module Tenji
  module Refinements
    refine Object do
      def is_a!(type)
        val = self.to_s.empty? ? 'NIL' : self
        msg = "Value #{val} is of type #{self.class.name}, expected #{type}"
        raise TypeError.new msg unless is_a? type
        self
      end
    end

    refine Pathname do
      def append_to_base(str)
        ext = self.extname
        base = self.sub_ext('').to_s
        Pathname.new(base + str + ext)
      end

      def exist!()
        msg = "File #{self} does not exist"
        raise StandardError.new msg unless self.exist?
      end

      def file!()
        msg = "File #{self} is not a file"
        raise StandardError.new msg if self.directory?
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
      def infix(pos, str)
        self[0...pos] + str + self[pos..-1]
      end
    end
  end
end
