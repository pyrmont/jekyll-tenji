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
      def exist!()
        msg = "File #{self} does not exist"
        raise StandardError.new msg unless self.exist?
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
  end
end
