require "pry-byebug"
require "schema_transfer"
require "fileutils"
require "shared_spec_setup"

module SpecHelpers
  def strip_heredoc(s)
    indent = s.scan(/^[ \t]*(?=\S)/).min.try(:size) || 0
    s.gsub(/^[ \t]{#{indent}}/, '')
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
