# frozen_string_literal: true

module Tenji
  class Queue
    using Tenji::Refinements
    
    DEFAULTS = { list_page:     nil,
                 gallery_pages: Hash.new,
                 image_files:   Hash.new { |h,k| h[k] = Array.new },
                 image_pages:   Hash.new { |h,k| h[k] = Hash.new },
                 thumb_files:   Hash.new { |h,k| h[k] = Hash.new { 
                                           |i,l| i[l] = Hash.new } },
                 cover_files:   Hash.new }

    attr_accessor *(DEFAULTS.keys)

    def initialize(prepared = nil)
      queue = merge(defaults, prepared)
      queue.each { |k,v| instance_variable_set("@#{k}", v) }
    end

    def to_a
      DEFAULTS.keys.map { |k| instance_variable_get("@#{k}") }
    end

    private def defaults()
      DEFAULTS.deep_copy
    end

    private def merge(hsh, ary)
      return hsh if ary.nil?

      hsh.each.with_index do |(k,v), index|
        next if ary[index].nil?
        hsh[k] = index == 0 ? ary[index] : v.merge(ary[index])
      end
    end
  end
end
