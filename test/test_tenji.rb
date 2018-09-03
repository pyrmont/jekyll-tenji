require 'test_helper'

describe Jekyll::Site do
  before do
    @temp_dir = Pathname.new('tmp') + ('a'..'z').to_a.shuffle[0,8].join
    @temp_dir.mkpath
    @site = TestSite.site source: 'test/data/site', dest: @temp_dir.to_s
  end

  after do
    @temp_dir.rmtree
    @site = nil
    Tenji::Config.reset
  end

  describe "#process" do
    it "renders a photo gallery" do
      @site.process
      expected = [ 'albums', 
                   'albums/gallery',
                   'albums/gallery/01-castle.html',
                   'albums/gallery/01-castle.jpg',
                   'albums/gallery/index.html',
                   'albums/gallery/thumbs',
                   'albums/gallery/thumbs/01-castle-small-2x.jpg',
                   'albums/gallery/thumbs/01-castle-small.jpg',
                   'albums/gallery/thumbs/cover-2x.jpg',
                   'albums/gallery/thumbs/cover.jpg',
                   'albums/index.html' ].map { |s| (@temp_dir + s).to_s }
      actual =  @temp_dir.glob('**/*').sort.map(&:to_s)
      assert_equal expected, actual
    end
  end
end
