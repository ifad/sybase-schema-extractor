class Extraction
  include SybaseSchema::Shared

  def self.perform(connection, schema_filename, tables=[])
    new(schema_filename, tables).
      perform(connection)
  end

  def initialize(schema_filename, tables=[])
    super schema_filename
    @tables = tables
  end

  def perform(connection)
    setup_database_tasks!(connection.to_sym)

    mark_tables_to_exclude!(connection)

    dump_schema!

    puts "Schema extracted to #{File.expand_path schema_filename}"
  end


  # SchemaDumper doesn't allow specifying tables, only which to exclude.
  # We have to calculate which ones to exclude by dumping the schema
  # first and subtracting the difference
  def mark_tables_to_exclude!(connection)
    dump_schema!

    ActiveRecord::SchemaDumper.ignore_tables = unused_tables()
  end

  def dump_schema!
    File.open(schema_filename, "w:utf-8") do |file|
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
    end
  end

  def unused_tables
    all_tables = read_schema_file.map do |t|
      match = t.match /create_table "([^"]+)"/
      match[1] if match
    end.compact

    all_tables - @tables
  end
end

