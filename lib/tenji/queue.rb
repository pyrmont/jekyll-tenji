# frozen_string_literal: true

module Tenji
  class Queue
    attr_accessor :cover_files, :gallery_pages, :image_pages, :image_files, :list_page, :thumb_files

    def initialize(prepared = nil)
      queue = Array.new
      queue[0] = nil
      queue[1] = Hash.new
      queue[2] = Hash.new { |h,k| h[k] = Array.new }
      queue[3] = Hash.new { |h,k| h[k] = Hash.new }
      queue[4] = Hash.new { |h,k| h[k] = Hash.new { 
                            |i,l| i[l] = Hash.new } }
      queue[5] = Hash.new

      queue[0] = prepared[0] if prepared && prepared[0]
      queue[1] = queue[1].merge(prepared[1]) if prepared && prepared[1]
      queue[2] = queue[2].merge(prepared[2]) if prepared && prepared[2]
      queue[3] = queue[3].merge(prepared[3]) if prepared && prepared[3]
      queue[4] = queue[4].merge(prepared[4]) if prepared && prepared[4]
      queue[5] = queue[5].merge(prepared[5]) if prepared && prepared[5]
      
      @list_page = queue[0]
      @gallery_pages = queue[1]
      @image_files = queue[2]
      @image_pages = queue[3]
      @thumb_files = queue[4]
      @cover_files = queue[5]
    end

    def to_a
      [ @list_page, @gallery_pages, @image_files, @image_pages, @thumb_files, @cover_files ]
    end
  end
end
