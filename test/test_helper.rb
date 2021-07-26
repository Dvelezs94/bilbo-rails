ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: 1)

  include FactoryBot::Syntax::Methods
  # Add more helper methods to be used by all tests here...
  include Devise::Test::IntegrationHelpers

  # converts a string to url friendly format.
  # e.g. "My awesome new ad" => "my-awesome-new-ad"
  def to_slug(text)
    text.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
  end
  
  def rand_time(from, to=Time.now.utc)
    Time.at(rand_in_range(from.to_f, to.to_f))
  end

  def rand_in_range(from, to)
    rand * (to - from) + from
  end
end
