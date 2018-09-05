require 'test_helper'

describe Tenji::Generator do
  before do
    @config = Tenji::Config
    @site = TestSite.site source: 'test/data/', dest: 'tmp/'
  end

  describe "#initialize" do
    it "instantiates a Tenji::Generator object" do
      generator = Tenji::Generator.new
      assert_equal Tenji::Generator, generator.class
      assert_equal Tenji::Config, generator.config
      assert_equal Tenji::Queue, generator.pre.class
      assert_equal Tenji::Queue, generator.post.class
    end
  end

  describe "#assign" do
    before do
      @config.configure

      factory = TestFactory.new @site, list: [ nil ], galleries: [ 'gallery/index.md', 'gallery2/' ], images: [ 'gallery/01-castle.jpg' ], pages: [ 'gallery/01-castle.md' ], thumbs: [ 'gallery/01-castle-small.jpg' ], covers: [ 'gallery/cover.jpg' ]    
      
      @obj = Tenji::Generator.new @site.config
      @obj.site = @site
      @obj.post = Tenji::Queue.new(factory.make :entities)

      @obj.post.image_files.each { |dirname, files| files.each { |file| file.data['page'] = @obj.post.image_pages[dirname][File.basename(file.name, '.*')] } }
      
      @expected = factory.make :entities, :array, @obj.post.to_a, flatten: true
    end

    after do
      @config.reset
    end

    it "assigns objects to the appropriate collections" do
      @obj.assign
      assert_equal [ @expected[0], *@expected[1], *@expected[3] ], @obj.site.pages
      assert_equal [ *@expected[2], *@expected[4], *@expected[5] ], @obj.site.static_files
    end
  end

  describe "#make" do
    before do 
      @config.configure

      factory = TestFactory.new @site, list: [ nil ], galleries: [ 'gallery/index.md', 'gallery2/' ], images: [ 'gallery/01-castle.jpg' ], pages: [ 'gallery/01-castle.md' ], thumbs: [ 'gallery/01-castle-small.jpg' ], covers: [ 'gallery/cover.jpg' ]

      @obj = Tenji::Generator.new @site.config
      @obj.site = @site
      @obj.pre = Tenji::Queue.new(factory.make :paths)

      @expected = factory.make :entities, :hash
    end

    after do
      @config.reset
    end

    it "builds a queue of entities" do
      @obj.make
      assert_equal @expected[:list], @obj.post.list_page
      assert_equal @expected[:galleries], @obj.post.gallery_pages
      assert_equal @expected[:images], @obj.post.image_files
      assert_equal @expected[:pages], @obj.post.image_pages
      assert_equal @expected[:thumbs], @obj.post.thumb_files
      assert_equal @expected[:covers], @obj.post.cover_files
    end
  end
  
  describe "#read" do
    before do
      @config.configure
      @obj = Tenji::Generator.new({ 'source' => @site.source })
    end

    after do
      @config.reset
    end

    it "builds a queue of file paths" do
      @obj.read
      parent = Tenji::Path.new(@obj.base) + @config.dir(:galleries)
      assert_equal({ 'gallery' => (parent + 'gallery/index.md') }, @obj.pre.gallery_pages)
      assert_equal({ 'gallery' => [ parent + 'gallery/01-castle.jpg' ] }, @obj.pre.image_files)
      assert_equal({ 'gallery' => { '01-castle' => (parent + 'gallery/01-castle.md') } }, @obj.pre.image_pages)
      assert_equal Hash.new, @obj.pre.thumb_files
    end
  end

  describe "#reference" do
    before do
      @config.configure

      factory = TestFactory.new @site, list: [ nil ], galleries: [ 'gallery/index.md', 'gallery2/' ], images: [ 'gallery/01-castle.jpg' ], pages: [ 'gallery/01-castle.md' ], thumbs: [ 'gallery/01-castle-small.jpg' ], covers: [ 'gallery/covery.jpg' ]
      
      @obj = Tenji::Generator.new @site.config
      @obj.post = Tenji::Queue.new(factory.make :entities)
      @obj.galleries = { 'all' => @obj.post.gallery_pages.values, 'hidden' => nil, 'listed' => @obj.post.gallery_pages.values }
    end

    after do
      @config.reset
    end

    it "adds references to the entities" do
      @obj.reference

      assert_equal @obj.post.gallery_pages.values, @obj.post.list_page.data['galleries']
      assert_equal @obj.post.image_files['gallery'], @obj.post.gallery_pages['gallery'].data['images']
      assert_equal @obj.post.cover_files['gallery'], @obj.post.gallery_pages['gallery'].data['cover']
      assert_equal @obj.post.image_files['gallery2'], @obj.post.gallery_pages['gallery2'].data['images']
      assert_equal @obj.post.thumb_files['gallery']['01-castle.jpg'], @obj.post.image_files['gallery'].first.data['sizes']
      assert_equal @obj.post.image_files['gallery'].first.path, @obj.post.cover_files['gallery'].source_path
    end
  end
  
  describe "#sort" do
    before do
      @config.configure

      factory = TestFactory.new @site, list: [ nil ], galleries: [ '3/', '2/', '1/' ], images: [ '1/03.jpg', '1/01.jpg', '1/02.jpg' ], pages: nil, thumbs: nil, covers: nil

      @obj = Tenji::Generator.new @site.config
      @obj.post = Tenji::Queue.new(factory.make :entities)
      @obj.galleries['all'] = @obj.post.gallery_pages.values

      @expected = factory.make :entities, :hash
    end

    after do
      @config.reset
    end

    it "sorts galleries and images based on filenames" do
      @obj.sort
      
      gallery_pages = @expected[:galleries].values.sort
      image_files = @expected[:images]['1'].sort.each.with_index { |el,i| el.position = i }

      assert_equal gallery_pages, @obj.galleries['all']
      assert_equal image_files, @obj.post.image_files['1']
    end

    it "sorts galleries based on internal data" do
      @obj.post.gallery_pages['3'].data = { 'period' => [ DateTime.new(1970, 1, 1) ] }
      @obj.sort

      gallery_pages = @expected[:galleries]['3'].data = { 'period' => [ DateTime.new(1970, 1, 1) ] }
      gallery_pages = @expected[:galleries].values.sort

      assert_equal gallery_pages, @obj.galleries['all']
    end
  end
  
  describe "#write" do
    before do
      @config.configure

      factory = TestFactory.new @site, images: [ 'gallery1/01.jpg', 'gallery1/02.jpg', 'gallery1/03.jpg' ], thumbs: [ 'gallery1/01-small.jpg', 'gallery1/02-small.jpg', 'gallery1/03-small.jpg' ], covers: [ 'gallery1/cover.jpg' ]
      
      site = TestSite.site source: 'test/data/', dest: 'tmp'
      base = site.source
      
      @obj = Tenji::Generator.new site.config
      @obj.post = Tenji::Queue.new(factory.make :entities)

      @images = @obj.post.image_files['gallery1']
      @thumbs = @obj.post.thumb_files['gallery1'].map { |k,v| v['small'] }
      @cover = @obj.post.cover_files['gallery1']
      
      @thumbs.each.with_index { |t,index| t.source_path = @images[index].path }
      @cover.source_path = @images.first.path
      
      @obj.writer = Minitest::Mock.new
    end

    after do
      @config.reset
    end

    it "writes thumbnails with Tenji::Writer" do
      @thumbs.each do |t|
        @config.scale_factors.each do |f|
          output_path = t.path[0...-4] + @config.scale_suffix(f) + '.jpg'
          constraints = @config.constraints('small', 'gallery1').transform_values { |v| v * f }
          @obj.writer.expect :write_thumb, nil, [ t.source_path, output_path, constraints, @config.resize_function('small', 'gallery1') ]
        end
      end

      @cover.yield_self do |c|
        @config.scale_factors.each do |f|
          output_path = c.path[0...-4] + @config.scale_suffix(f) + '.jpg'
          constraints = @config.constraints(:cover).transform_values { |v| v * f }
          @obj.writer.expect :write_thumb, nil, [ c.source_path, output_path, constraints, @config.resize_function(:cover) ]
        end
      end

      @obj.write

      @obj.writer.verify
    end
  end
end
