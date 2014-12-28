require "active_record"
require "active_record/connection_adapters/sybase_adapter"
require "yaml"

require "./lib/shared"
require "./lib/extraction"
require "./lib/insertion"
require "./lib/yaml_active_record_connection"
require "./lib/remove_string_primary_key"
require "./lib/adapter_specific_transformation"

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
      AdapterSpecificTransformation.perform(@from, @to, filename)
      Insertion.perform(@to,    filename)
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


end

