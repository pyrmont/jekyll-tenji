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

Jekyll.logger.log_level = :error

class TestSite
  def self.site(source:, dest:)
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
