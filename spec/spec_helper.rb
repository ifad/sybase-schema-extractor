require "pry-byebug"
require "schema_transfer"
require "fileutils"
require "shared_spec_setup"

require "database_cleaner"

module SpecHelpers
  extend self

  def drop_db(env)
    as_db_admin(env) do |connection, db|
      connection.drop_database db
    end
  end

  def create_db(env)
    as_db_admin(env) do |connection, db|
      connection.create_database db
    end
  end

  def as_db_admin(env)
    ActiveRecord::Base.tap do |b|
      b.establish_connection :postgres_admin_db
      config = ActiveRecord::Base.configurations[env]
      yield b.connection, config[:database]
    end
  end


  def strip_heredoc(s)
    indent = s.scan(/^[ \t]*(?=\S)/).min.try(:size) || 0
    s.gsub(/^[ \t]{#{indent}}/, '')
  end
  #It's easier to compare/test ruby code without leading whitespace.
  #ideally we'd handle this nicely but the
  #schema files are only normally present during a schema extraction/insertion
  def kill_leading_whitespace!(s)
    if s.is_a?(Array)
      s.map{|i| kill_leading_whitespace!(i)}
    else
      s.gsub!(/^ */,"").chomp
      s.gsub!(/\A\n/,"")
      s.gsub!(/\n\z/,"")
      s
    end
  end

  def kw!(s)
    kill_leading_whitespace!(s)
  end


end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.include SpecHelpers

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:suite) do
    YamlActiveRecordConnection.establish! "config/database.yml"
    SpecHelpers.drop_db :test
    SpecHelpers.create_db :test

    ActiveRecord::Base.establish_connection :test

    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation, :cache_tables => false)
  end

  config.around(:each) do |example|
    if example.metadata[:skip_db_cleaner]
      example.run
    else
      ActiveRecord::Base.establish_connection :test
      DatabaseCleaner.cleaning do
        example.run
      end
    end
  end


  config.disable_monkey_patching!
  config.warnings = true
  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  #config.profile_examples = 10

  config.order = :random

  Kernel.srand config.seed
end
