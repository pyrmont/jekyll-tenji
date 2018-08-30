# frozen_string_literal: true

module Tenji
  class ConfigurationNotSetError < ::StandardError
    def to_s
      'Configuration not set'
    end
  end

  class ConfigurationError < ::StandardError
  end

  class NotAFileError < ::StandardError
  end

  class NotFoundError < ::StandardError
  end

  class ResizeError < ::StandardError
  end
end
