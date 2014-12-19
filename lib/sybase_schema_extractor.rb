require "active_record"
require "active_record/connection_adapters/sybase_adapter"
require "yaml"

class SybaseSchemaExtractor
  def self.perform(config, connection, schema_filename)
    new(config).perform(connection, schema_filename)
  end

  def initialize(config)
    @config = YAML.load File.read(config)
    ActiveRecord::Base.configurations = @config
  end

  def perform(connection, schema_filename)
    setup_database_tasks!
    ActiveRecord::Base.establish_connection(connection.to_sym)

    File.open(schema_filename, "w:utf-8") do |file|
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
    end

    puts "Schema extracted to #{File.expand_path schema_filename}"
  end

  private

  def write_schema!
    ActiveRecord::Base.configurations = yaml
    ActiveRecord::Base.establish_connection(yaml.fetch("test"))
    load_schema
  end

  def setup_database_tasks!
    tasks = ActiveRecord::Tasks::DatabaseTasks
    tasks.database_configuration = @config
    tasks.env = "test"
  end

  def load_schema(filename)
    ActiveRecord::Tasks::DatabaseTasks.load_schema(:ruby, filename)
  end
end
