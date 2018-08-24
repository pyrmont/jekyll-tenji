# frozen_string_literal: true

module Tenji
  module Scalable
    def scales(scale_factors)
      scale_factors.map do |f|
        if f == 1
          self
        else
          scaled = self.dup
          scaled.scale = f
          scaled
        end
      end
    end
  end
end
