# frozen_string_literal: true

module Tenji
  class ConfigurationError < ::StandardError
  end

  module Config
    class InvalidSortError < ::StandardError
      def to_s
        'The defined sort order is invalid'
      end
    end

    class NoDocumentError < ::StandardError
      def to_s
        'The given document type does not exist'
      end
    end

    class NoGalleryError < ::StandardError
      def to_s
        'No gallery exists for the given directory name'
      end
    end

    class NoGalleryTypeError < ::StandardError
      def to_s
        'The given gallery type does not exist'
      end
    end

    class NoKeyError < ::StandardError
      def to_s
        'No configuration option exists for the given key'
      end
    end

    class NoSizeError < ::StandardError
      def to_s
        'No options for the given size'
      end
    end

    class NoSortTypeError < ::StandardError
      def to_s
        'The given sort type does not exist'
      end
    end  

    class NotGalleryLevelError < ::StandardError
      def to_s
        'The given option is not one set at the gallery level'
      end
    end
  end

  class NotAFileError < ::StandardError
  end

  class NotFoundError < ::StandardError
  end

  class ResizeError < ::StandardError
  end
end
