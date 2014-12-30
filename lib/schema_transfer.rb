require "active_record"
require "active_record/connection_adapters/sybase_adapter"
require "yaml"

require "./lib/shared"
require "./lib/extraction"
require "./lib/insertion"
require "./lib/yaml_active_record_connection"
require "./lib/schema_table_helpers"
require "./lib/execute_string_primary_key_migrations"
require "./lib/remove_integer_primary_key"

class SchemaTransfer
  def self.perform(*args)
    new(*args).perform
  end

  def initialize(from: "production", to: "test",
                 tables: [],         config: "config/database.yml")
    YamlActiveRecordConnection.establish! config
    @from = from
    @to = to
    parse(tables)
  end

  def perform
    with_tempfile do |filename|
      Extraction.perform(@from, filename, @tables)

      RemoveIntegerPrimaryKey.perform(filename) if alter_string_primary_keys?

      Insertion.perform(@to, filename)

      if alter_string_primary_keys?
        ExecuteStringPrimaryKeyMigrations.perform(filename, @from, @to)
      end
    end

    puts "transferred schema from #{@from} to #{@to}"
  end

  private

  def parse(tables)
    if tables.is_a?(Array)
      @tables = tables
    elsif tables.is_a?(String)
      @tables = File.readlines(tables).map(&:chomp)
    else
      raise ArgumentError.new "Expected an array of table names or filename with a list of tables to use"
    end
  end


  def with_tempfile
    file = Tempfile.new("schema.rb")
    begin
      yield file.path
    ensure
      file.close
      file.unlink
    end
  end

  def alter_string_primary_keys?
    (from_adapter == "sybase") && (to_adapter == "postgresql")
  end

  def adapter(connection)
    ActiveRecord::Base.configurations[connection][:adapter]
  end

  def to_adapter
    adapter @to
  end

  def from_adapter
    adapter @from
  end
end
