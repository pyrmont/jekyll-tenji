require 'test_helper'

class TenjiConfigTest < Minitest::Test
  context "Tenji::Config" do
    setup do
      @defaults = Tenji::Config::DEFAULTS
    end

    context "has a class method .configure that" do
      should "return a Hash with default values with no arguments" do
        obj = Tenji::Config.configure
        assert_equal 'Hash', obj.class.name
        assert_equal @defaults, obj
        Tenji::Config.reset
      end

      should "return a Hash with custom values with an options hash" do
        options = { 'galleries_dir' => '_galleries' }
        obj = Tenji::Config.configure options
        assert_equal options['galleries_dir'], obj['galleries_dir']
        assert_equal @defaults['thumbs_dir'], obj['thumbs_dir']
        Tenji::Config.reset
      end

      should "raise an error if an invalid argument is passed" do
        assert_raises(StandardError) { Tenji::Config.configure nil }
      end
    end

    context "has a class method .reset that" do
      should "set the state object to nil" do
        Tenji::Config.configure
        obj = Tenji::Config.config
        assert_equal @defaults, obj
        Tenji::Config.reset
        assert_nil Tenji::Config.instance_variable_get :@config
      end
    end

    context "has a class method .config that" do
      should "return the state object" do
        Tenji::Config.configure
        obj = Tenji::Config.config
        assert_equal @defaults, obj
        Tenji::Config.reset
      end

      should "raise an error if the state object has not been set" do
        assert_raises(StandardError) { Tenji::Config.config }
      end
    end

    context "has a class method .dir that" do
      setup do
        @obj = Tenji::Config
        @obj.configure
      end

      teardown do
        @obj.reset
      end

      should "return a directory name for a valid key" do
        dirname = 'galleries'
        default_dir = @defaults[dirname + '_dir']
        assert_equal default_dir, @obj.dir(dirname)
        assert_equal default_dir.delete_prefix('_'), 
                     @obj.dir(dirname, output: true)
      end

      should "return nil for a non-existent key" do
        assert_nil @obj.dir('Does not exist')
      end

      should "raise an error if the state object has not been set" do
        @obj.reset
        assert_raises(StandardError) { @obj.dir('something') }
      end
    end

    context "has a class method .ext that" do
      setup do
        @obj = Tenji::Config
        @obj.configure
      end

      teardown do
        @obj.reset
      end

      should "return an extension name for a valid key" do
        extname = 'page'
        default_internal_ext = @defaults['input_' + extname + '_ext']
        default_external_ext = @defaults['output_' + extname + '_ext']
        assert_equal default_internal_ext, @obj.ext(extname)
        assert_equal default_external_ext, @obj.ext(extname, output: true)
      end

      should "return nil for a non-existent key" do
        assert_nil @obj.ext('Does not exist')
      end

      should "raise an error if the state object has not been set" do
        @obj.reset
        assert_raises(StandardError) { @obj.ext('something') }
      end
    end

    context "has a class method .file that" do
      setup do
        @obj = Tenji::Config
        @obj.configure
      end

      teardown do
        @obj.reset
      end

      should "return a file name for a valid key" do
        filename = 'metadata'
        default_filename = @defaults['metadata_file']
        assert_equal default_filename, @obj.file(filename)
      end

      should "return nil for a non-existent key" do
        assert_nil @obj.file('Does not exist')
      end

      should "raise an error if the state object has not been set" do
        @obj.reset
        assert_raises(StandardError) { @obj.file('something') }
      end
    end

    context "has a class method .settings that" do
      setup do
        @settings = { 'gallery_settings' => { 'originals' => false } }
        @obj = Tenji::Config
        @obj.configure @settings
      end

      teardown do
        @obj.reset
      end

      should "return a file name for a valid key" do
        setting_name = 'gallery'
        assert_equal @settings[setting_name + '_settings'], 
                     @obj.settings(setting_name)
      end

      should "return nil for a non-existent key" do
        assert_nil @obj.settings('Does not exist')
      end

      should "raise an error if the state object has not been set" do
        @obj.reset
        assert_raises(StandardError) { @obj.settings('something') }
      end
    end
  end
end
