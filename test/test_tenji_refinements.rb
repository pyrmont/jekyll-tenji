require 'test_helper'

class TenjiRefinementsTest < Minitest::Test
  using Tenji::Refinements

  context "Tenji::Refinements" do
    context "refines Object with a method #is_a! that" do
      should "return self if the type matches" do
        obj = 10
        assert_equal obj, obj.is_a!(Integer) 
        assert_equal obj, obj.is_a!(Numeric)

        obj = 'String'
        assert_equal obj, obj.is_a!(String)
      end

      should "raise an error if the type doesn't match" do
        obj = 10
        assert_raises(TypeError) { obj.is_a!(String) }

        obj = 'String'
        assert_raises(TypeError) { obj.is_a!(Integer) }
      end
    end

    context "refines Pathname with a method #append_to_base that" do
      should "return a Pathname object with a string appended to the base" do
        obj = Pathname.new '/path/to/a/file.rb'
        assert_equal '/path/to/a/file2.rb', obj.append_to_base('2').to_s
        assert_equal obj.to_s, obj.append_to_base('').to_s
        obj = Pathname.new '/path/to/a/file'
        assert_equal '/path/to/a/file2', obj.append_to_base('2').to_s
        assert_equal obj.to_s, obj.append_to_base('').to_s
      end
    end

    context "refines Pathname with a method #exist! that" do
      should "not raise an error if the path exists" do
        obj = Pathname.new 'test'
        assert_nil obj.exist!
      end

      should "raise an error if the path doesn't exist" do
        obj = Pathname.new '/does/not/exist/'
        assert_raises(StandardError) { obj.exist! }
      end
    end

    context "refines Pathname with a method #file! that" do
      should "not raise an error if the file exists" do
        obj = Pathname.new 'test/data/gallery1/photo1.jpg'
        assert_nil obj.file!
      end

      should "raise an error if the file doesn't exist" do
        obj = Pathname.new 'test/data/gallery1'
        assert_raises(StandardError) { obj.file! }
      end
    end

    context "refines Pathname with a method #images that" do
      should "return an array of Pathnames representing images" do
        path = 'test/data/gallery1'
        obj = Pathname.new path
        assert_equal [ Pathname.new(path + '/photo1.jpg') ], obj.images
      end

      should "return an empty array if there are no images" do
        obj = Pathname.new 'test'
        assert_equal Array.new, obj.images
      end
    end

    context "refines Pathname with a method #subdirectories that" do
      should "return an array of Pathnames representing subdirectories" do
        path = 'test/data/_albums'
        obj = Pathname.new path
        assert_equal [ Pathname.new(path + '/gallery') ], obj.subdirectories
      end

      should "return an empty array if there are no subdirectories" do
        obj = Pathname.new 'test/data/gallery1'
        assert_equal Array.new, obj.subdirectories
      end
    end

    context "refines String with a method #append_to_base that" do
      should "return a string with a string appended to the base" do
        obj = '/path/to/a/file.rb'
        assert_equal '/path/to/a/file2.rb', obj.append_to_base('2')
        assert_equal obj, obj.append_to_base('')
        obj = '/path/to/a/file'
        assert_equal '/path/to/a/file2', obj.append_to_base('2')
        assert_equal obj, obj.append_to_base('')
      end
    end

    context "refines String with a method #infix that" do
      should "return a string with a string inserted" do
        obj = 'An example'
        assert_equal 'An insignificant example', obj.infix(3, 'insignificant ')
        assert_equal 'An example!', obj.infix(obj.length, '!')
      end

      should "return nil if the position is invalid" do
        obj = "An example"
        assert_nil obj.infix(11, '!')
        assert_nil obj.infix(-11, '>')
      end
    end

    context "refines String with a method #sub_ext that" do
      should "return a string with a replaced extension" do
        obj = 'file.py'
        assert_equal 'file.rb', obj.sub_ext('.rb')
        obj = 'file'
        assert_equal 'file.rb', obj.sub_ext('.rb')
      end
    end
  end
end
