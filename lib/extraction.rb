class Extraction
  include SybaseSchema::Shared

  def self.perform(config_filename, connection, schema_filename, tables_to_include_filename=nil)
    new(config_filename, schema_filename).
      perform(connection, tables_to_include_filename)
  end

  def perform(connection, tables_to_include_filename=nil)
    setup_database_tasks!(connection.to_sym)
    ActiveRecord::Base.establish_connection(connection.to_sym)

    mark_tables_to_exclude!(connection, tables_to_include_filename)

    dump_schema!

    puts "Schema extracted to #{File.expand_path schema_filename}"
  end


  # SchemaDumper doesn't allow specifying tables, only which to exclude.
  # We have to calculate which ones to exclude by dumping the schema
  # first and subtracting the difference
  def mark_tables_to_exclude!(connection, filename)
    return unless  File.exists?(filename.to_s)

    dump_schema!

    ActiveRecord::SchemaDumper.ignore_tables = unused_tables(filename)
  end

  def dump_schema!
    File.open(schema_filename, "w:utf-8") do |file|
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
    end
  end

  def unused_tables(tables_to_include_filename)
    wanted_tables = read_included_tables(tables_to_include_filename).split "\n"

    all_tables = read_schema_file.map do |t|
      match = t.match /create_table "([^"]+)"/
      match[1] if match
    end.compact

    all_tables - wanted_tables
  end

  def read_included_tables(tables_to_include_filename)
    File.read(tables_to_include_filename)
  end
end

