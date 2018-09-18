# frozen_string_literal: true

module Tenji

  # The refinements used by Tenji
  #
  # {Tenji::Refinements} collects together the refinements to core classes.
  #
  # @since 0.1.0
  # @api private
  module Refinements
    refine Hash do

      # Create a copy of a hash with no shared references to values that are
      # Hash objects
      #
      # This refinement does not attempt to be of general application. Other
      # data structures where copying can create shared references are not
      # avoided by use of this method.
      #
      # @return [Hash] a copy of the original without shared references
      #
      # @since 0.1.0
      # @api private
      def deep_copy()
        reduce(dup) do |memo,(k,v)|
          value = v.is_a?(Hash) ? v.deep_copy : v.dup
          memo.update({ k => value })
        end
      end

      # Merge itself with another hash (including nested values)
      #
      # Ruby's `Hash#merge` method does not recurse into nested levels of the
      # hashes to be merged. This refinement provides that level of depth.
      #
      # @param h [Hash] the hash to merge
      #
      # @return [Hash] the merged hash
      #
      # @since 0.1.0
      # @api private
      def deep_merge(h)
        reduce(merge(h)) do |memo,(k,v)|
          next memo unless h.key?(k) && h[k].is_a?(Hash)
          memo.update({ k => v.deep_merge(h[k]) })
        end
      end
    end

    refine String do

      # Append `str` to the 'base'
      #
      # This refinement is a convenience method for processing strings that
      # represent paths in the file system. If the 'basename' of a path is the
      # portion of the path after the final directory delimiter, the 'base' is
      # the portion of the basename, before the extension (or it is simply the
      # basename if there is no file extension). This method appends the given
      # parameter to this portion.
      #
      # @param str [String] the string to append
      #
      # @return [String] the appended string
      #
      # @since 0.1.0
      # @api private
      def append_to_base(str)
        pos = rindex('.') || length
        self[0...pos] + str + self[pos..-1]
      end
    end
  end
end
