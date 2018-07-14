# frozen_string_literal: true

module Tenji
  class ConfigurationNotSetError < ::StandardError
    def to_s
      'Configuration not set'
    end
  end

  class NotAFileError < ::StandardError
  end

  class NotFoundError < ::StandardError
  end

  class TypeError < ::StandardError
  end
end