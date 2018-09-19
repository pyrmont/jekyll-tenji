# frozen_string_literal: true

module Tenji
  
  # A queue of paths for processing
  #
  # {Tenji::Queue} is a special collection of file paths. In addition to 
  # providing separate production 'lines' for the different types of files, each 
  # line provides different default values. This allows for the generating code
  # to be simpler.
  #
  # Tenji uses two queues for the generation process. The first queue is a 
  # collection of paths for pre-production. The second queue is a collection of
  # paths for post-production.
  #
  # @since 0.1.0
  # @api private
  class Queue
    using Tenji::Refinements
    
    # The production lines with default values
    #
    # @since 0.1.0
    # @api private
    DEFAULTS = { list_page:     nil,
                 gallery_pages: Hash.new,
                 image_files:   Hash.new { |h,k| h[k] = Array.new },
                 image_pages:   Hash.new { |h,k| h[k] = Hash.new },
                 thumb_files:   Hash.new { |h,k| h[k] = Hash.new { 
                                           |i,l| i[l] = Hash.new } },
                 cover_files:   Hash.new }

    attr_accessor *(DEFAULTS.keys)

    # Initialise an object of this class
    #
    # @param prepared [Hash] a pre-prepared collection
    #
    # @return [Tenji::Queue] the intialised object 
    def initialize(prepared = nil)
      queue = merge(defaults, prepared)
      queue.each { |k,v| instance_variable_set("@#{k}", v) }
    end

    # Return the values in the queue as an array
    #
    # This is used for testing purposes.
    #
    # @return [Array] the queue
    #
    # @since 0.1.0
    # @api private
    def to_a
      DEFAULTS.keys.map { |k| instance_variable_get("@#{k}") }
    end

    # Return the default values
    #
    # To avoid the problem where nested values would be shared between
    # different instances of {Tenji::Queue}, this method returns a deep copy of
    # {Tenji::Queue::DEFAULTS}.
    #
    # @return [Hash] the default values
    #
    # @since 0.1.0
    # @api private
    private def defaults()
      DEFAULTS.deep_copy
    end

    # Merge a hash with an ordered array
    #
    # @param hsh [Hash] the hash to merge
    # @param ary [Array] the array to merge
    #
    # @return [Hash] the merged hash
    #
    # @since 0.1.0
    # @api private
    private def merge(hsh, ary)
      return hsh if ary.nil?

      hsh.each.with_index do |(k,v), index|
        next if ary[index].nil?
        hsh[k] = index == 0 ? ary[index] : v.merge(ary[index])
      end
    end
  end
end
