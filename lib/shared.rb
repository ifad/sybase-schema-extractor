class SybaseSchema
  module Shared
    attr_reader :schema_filename

    def initialize(config_filename, schema_filename)
      @schema_filename = schema_filename
      config = YAML.load(File.read(config_filename)).with_indifferent_access
      ActiveRecord::Base.configurations = config
    end

    def read_schema_file
      File.readlines(schema_filename)
    end

    def setup_database_tasks!(env)
      tasks = ActiveRecord::Tasks::DatabaseTasks
      tasks.database_configuration = @config
      tasks.env = env

      ActiveRecord::Base.establish_connection(env.to_sym)
    end
  end
end
