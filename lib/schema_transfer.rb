require "active_record"
require "active_record/connection_adapters/sybase_adapter"
require "yaml"
require "./lib/shared"
require "./lib/extraction"
require "./lib/insertion"
require "./lib/yaml_active_record_connection"

class SchemaTransfer
  def initialize(from: "production", to: "test", 
                 tables: [],
                 schema_filename: "./tmp/schema.rb",
                 config: "config/database.yml")
    YamlActiveRecordConnection.establish! config

    @from = from
    @tables = tables
    @to = to
    @schema_filename = schema_filename
  end

  def perform
    Extraction.perform(@from, @schema_filename, @tables)
    Insertion.new(@schema_filename).perform(@to)
  end

end

