module Tenji
  module Verify
    def verify(*args)
      args.each do |a|
        raise Tenji::Verify::TypeError.new(a[0], a[1]) unless a[0].is_a? a[1]
      end
    end

    class TypeError < StandardError
      def initialize(obj, type)
        msg = "Object with value '#{obj}' was expected to be type #{type} but is of type #{obj.class.name}"
        super(msg)
      end
    end
  end
end