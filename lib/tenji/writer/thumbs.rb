require 'rmagick'

module Tenji
  module Writer
    class Thumbs
      def self.write(thumbs, output_dir, sizes)
        input_path = thumbs.source.realpath.to_s
        input_name = thumbs.source.basename.sub_ext('').to_s
        sizes.each do |name,size|
          output_basename = "#{input_name}-#{name}.jpg"
          output_path = (output_dir + output_basename).expand_path.to_s
          image = Magick::ImageList.new input_path
          image.auto_orient!
          image.resize_to_fit! size['x'], size['y']
          image.write output_path
          thumbs[name] = output_path
        end
      end
    end
  end
end