module SharedSpecSetup
  def adapter
    ActiveRecord::Base.connection.adapter_name
  end

  def config_filename
    "./config/database.yml"
  end

  def schema_filename
    "./tmp/schema.rb"
  end

  def include_table_file
    "config/include_tables.txt"
  end

  def tables
    ActiveRecord::Base.connection.tables.sort
  end

  def self.included(base)
    base.class_eval do
      before do
        FileUtils.rm_rf "./tmp/schema.rb"
        ActiveRecord::SchemaDumper.ignore_tables = []
        YamlActiveRecordConnection.establish!(config_filename)
      end
    end
  end

  def with_connection(environment)
    old = ActiveRecord::Base.connection_config rescue nil
    ActiveRecord::Base.establish_connection environment
    yield
    ActiveRecord::Base.establish_connection old if old
  end


  #don't memoize so we can re-read after changes
  def schema
    File.read(schema_filename) rescue nil
  end
end
