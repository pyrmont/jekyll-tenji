require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'minitest/reporters'
require 'shoulda/context'

# Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
# Minitest::Reporters.use!

require 'jekyll'

class TestSite
  @@site = nil

  def self.reset
    Jekyll.logger.log_level = :error
    source_dir = Pathname.new('test/data').realpath.to_s
    dest_dir = Pathname.new('tmp').realpath.to_s
    config = Jekyll.configuration({ 'source' => source_dir,
                                    'destination' => dest_dir,
                                    'url' => 'http://localhost' })
    @@site = Jekyll::Site.new config
  end

  def self.site
    return @@site if @@site
    self.reset
  end
end
