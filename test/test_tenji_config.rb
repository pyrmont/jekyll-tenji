require 'test_helper'

describe Tenji::Config do
  before do
    @obj = Tenji::Config
    @obj.configure
    @config = @obj.instance_variable_get :@config
  end

  after do
    @obj.reset
    @config = nil
  end

  describe "::configure" do
    before do
      @defaults = Tenji::Config::DEFAULTS.dup.update({ 'gallery' => Hash.new })
      @obj.reset
    end

    it "configures the Tenji::Config object with the default settings" do
      @obj.configure
      assert_equal @defaults, @obj.instance_variable_get(:@config)
    end

    it "configures the Tenji::Config object with the custom settings" do
      @obj.configure({ 'foo' => 5 })
      assert_equal @defaults.merge({ 'foo' => 5 }), @obj.instance_variable_get(:@config)
    end
  end

  describe "::reset" do
    it "resets the settings of Tenji::Config" do
      assert @obj.instance_variable_get(:@config)
      @obj.reset
      assert_nil @obj.instance_variable_get(:@config)
    end
  end

  describe "::debug" do
    it "returns the internal Hash object used to store the settings" do
      assert_equal @config, @obj.debug
    end
  end

  describe "::add_config" do
    it "adds configuration options for a gallery" do
      assert_equal Hash.new, @config['gallery']['foo']
      @obj.add_config 'foo', { 'bar' => 42 }
      assert_equal 42, @config['gallery']['foo']['bar']
    end
  end

  describe "::constraints" do
    it "returns the size constraints for the cover" do
      assert_equal Hash['x' => 200, 'y' => 200], @obj.constraints(:cover)
    end

    it "returns the size constraints for an arbitrary size and gallery" do
      @config['gallery']['foo']['sizes'] = { 'unusual' => { 'resize' => 'fit', 'x' => 300, 'y' => 50 } }
      assert_equal Hash['x' => 300, 'y' => 50], @obj.constraints('unusual', 'foo')
    end
  end

  describe "::cover" do
    it "returns the filename of the cover image if set for the gallery" do
      @config['gallery']['foo']['cover'] = 'bar.jpg'
      assert_equal 'bar.jpg', @obj.cover('foo')
    end
    
    it "returns nil if no cover image set for the gallery" do
      assert_nil @obj.cover('foo')
    end
  end
  
  describe "::dir" do
    it "returns a Tenji::Path object for either :galleries or :thumbs" do
      assert_equal Tenji::Path.new('_albums'), @obj.dir(:galleries)
      assert_equal Tenji::Path.new('_thumbs'), @obj.dir(:thumbs)
    end

    it "returns nil if the key doesn't exist" do
      assert_nil @obj.dir('foo')
    end
  end

  describe "::hidden?" do
    it "returns true if the given gallery is hidden" do
      @config['gallery']['foo']['hidden'] = true
      assert @obj.hidden?('foo')
    end

    it "returns false if the given gallery is not hidden" do
      @config['gallery']['foo']['hidden'] = false
      refute @obj.hidden?('foo')
    end
    
    it "returns the default value if there is no setting for the given gallery" do
      refute @obj.hidden?('foo')
      @config['gallery_settings']['hidden'] = true
      assert @obj.hidden?('foo')
    end
  end

  describe "::items_per_page" do
    it "returns the number of items which trigger a new page for the list" do
      assert_equal 10, @obj.items_per_page
    end

    it "returns the number of items which trigger a new page for a given gallery" do
      @config['gallery']['foo']['images_per_page'] = 100
      assert_equal 100, @obj.items_per_page('foo')
    end

    it "returns the default number of items which trigger a new page if there is no setting for the given gallery" do
      assert_equal 25, @obj.items_per_page('foo')
    end
  end

  describe "::option" do
    it "returns a setting for a given key" do
      assert_equal '_albums', @obj.option('galleries_dir')
    end

    it "returns a setting for a given key and a given gallery" do
      assert_equal 'gallery_index', @obj.option('layout', 'foo')
      @config['gallery']['foo']['layout'] = 'custom'
      assert_equal 'custom', @obj.option('layout', 'foo')
    end

    it "returns nil if the key doesn't exist" do
      assert_nil @obj.option('foo')
      assert_nil @obj.option('scale_max', 'foo')
    end
  end

  describe "::resize_function" do
    it "returns the resize function for the cover image" do
      assert_equal 'fill', @obj.resize_function(:cover)
    end

    it "returns the default resize function for a given gallery and given thumbnail size" do
      assert_equal 'fit', @obj.resize_function('small', 'foo')
    end

    it "returns the custom resize function for a given gallery and given thumbnail size" do
      @config['gallery']['foo']['sizes'] = { 'large' => { 'resize' => 'custom' } }
      assert_equal 'custom', @obj.resize_function('large', 'foo')
    end
  end

  describe "::scale_factors" do
    it "returns a range from 1 to the maximum scale factor" do
      assert_equal (1..2), @obj.scale_factors
    end
  end

  describe "::set" do
    it "sets a new configuration option at the top level" do
      assert_nil @config['foo']
      @obj.set 'foo', 42
      assert_equal 42, @config['foo']
    end

    it "sets an existing configuration option at the top level" do
      assert_equal 10, @config['galleries_per_page']
      @obj.set 'galleries_per_page', 42
      assert_equal 42, @config['galleries_per_page']
    end

    it "sets a new configuration option at the gallery level" do
      assert_nil @config['gallery']['foo']['bar']
      @obj.set 'bar', 42, 'foo'
      assert_equal 42, @config['gallery']['foo']['bar']
    end

    it "sets an existing configuration option at the gallery level" do
      @config['gallery']['foo']['bar'] = 21
      @obj.set 'bar', 42, 'foo'
      assert_equal 42, @config['gallery']['foo']['bar']
    end
  end

  describe "::settings" do
    it "returns the settings associated with a key" do
      assert_equal @config['gallery_settings'], @obj.settings(:gallery)
    end
  end

  describe "::sort" do
    before do
      @asc = 1
      @desc = -1
      @ignore = :ignore
    end

    it "returns the default sort order for the top-level setting" do
      assert_equal @asc, @obj.sort('name')
      assert_equal @desc, @obj.sort('period')
    end

    it "returns the default sort order for the gallery-level setting" do
      assert_equal @asc, @obj.sort('name', 'foo')
      assert_equal @desc, @obj.sort('period', 'foo')
    end

    it "returns a descending sort order" do
      @config['gallery']['foo']['sort'] = { 'name' => 'desc', 'period' => 'desc' }
      assert_equal @desc, @obj.sort('name', 'foo')
      assert_equal @desc, @obj.sort('period', 'foo')
    end

    it "returns an ascending sort order" do
      @config['gallery']['foo']['sort'] = { 'name' => 'asc', 'period' => 'asc' }
      assert_equal @asc, @obj.sort('name', 'foo')
      assert_equal @asc, @obj.sort('period', 'foo')
    end

    it "returns an ignore code for a characteristic to ignore" do
      @config['gallery']['foo']['sort'] = { 'period' => 'ignore' }
      assert_equal @ignore, @obj.sort('period', 'foo')
    end
  end

  describe "::thumb_sizes" do
    it "returns the settings for thumbs" do
      expected = { 'small' => { 'resize' => 'fit', 'x' => 400 } }
      assert_equal expected, @obj.thumb_sizes('foo')
    end
  end
end
