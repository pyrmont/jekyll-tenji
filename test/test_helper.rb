require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'minitest/reporters'
require 'shoulda/context'

# Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
# Minitest::Reporters.use!

require 'pathname'
require 'jekyll'
require 'jekyll-tenji'

class TestSite
  def self.site(source:, dest:, log_level: :error)
    Jekyll.logger.log_level = log_level
    source_dir = Pathname.new(source).realpath.to_s
    dest_dir = Pathname.new(dest).realpath.to_s
    config = Jekyll.configuration({ 'source' => source_dir,
                                    'destination' => dest_dir,
                                    'url' => 'http://localhost' })
    Jekyll::Site.new config
  end
end

class AnyType
  using Tenji::Refinements

  def is_a?(type)
    true
  end
end
