module Tenji
  module Refinements
    refine Pathname do
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
