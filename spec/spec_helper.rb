require 'simple_messenger'
require 'rspec/autorun'
require 'shoulda-matchers'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory:"
)

load(File.dirname(__FILE__) + '/extra/schema.rb')
load(File.dirname(__FILE__) + '/extra/models.rb')

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end
