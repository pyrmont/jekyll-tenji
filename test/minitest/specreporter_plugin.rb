module Minitest
  class SpecReporter < Minitest::AbstractReporter
    def record(result)
      class_name = result.instance_variable_get(:@klass)
      components = if class_name.index '::::'
                     class_name.split '::::'
                   elsif class_name.index '::#'
                     class_name.split '::#'
                   end
      result.instance_variable_set(:@klass, components[0])

      desc = result.instance_variable_get(:@NAME).sub(/test_\d+_/, '')
      result.instance_variable_set(:@NAME, "#{components[1].gsub(/::/, ' ')} #{desc}")
    end
  end
  
  def self.plugin_specreporter_init(options)
    Minitest.reporter << SpecReporter.new
  end
end
