require 'rmagick'

module Tenji
  class Gallery
    class Image
    
      attr_accessor :name, :thumbs
      
      def initialize(file)
        msg = "The file #{file} doesn't exist."
        raise StandardError, msg unless file.exist?

        @name = file.basename.to_s
        @thumbs = Tenji::Gallery::Image::Thumb.new file 
      end

      def generate_thumbs(output_dir, sizes)
        @thumbs.generate output_dir, sizes
      end

      class Thumb
        attr_reader :files, :source

        def initialize(source)
          @files = Hash.new
          @source = source
        end

        def [](k)
          @files[k]
        end

        def generate(output_dir, sizes)
          input_path = @source.realpath.to_s
          input_name = @source.basename.sub_ext('').to_s
          sizes.each do |name,size|
            output_basename = "#{input_name}-#{name}.jpg"
            output_path = (output_dir + output_basename).expand_path.to_s
            image = Magick::ImageList.new input_path
            image.auto_orient!
            image.resize_to_fit! size['x'], size['y']
            image.write output_path
            @files[name] = output_path
          end
        end
      end
    end
  end
end
