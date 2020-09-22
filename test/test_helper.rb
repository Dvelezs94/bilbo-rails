ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  include FactoryBot::Syntax::Methods
  # Add more helper methods to be used by all tests here...
  include Devise::Test::IntegrationHelpers

  # converts a string to url friendly format.
  # e.g. "My awesome new ad" => "my-awesome-new-ad"
  def to_slug(text)
    text.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
  end
end
