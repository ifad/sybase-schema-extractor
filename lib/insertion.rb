class Insertion
  include SybaseSchema::Shared

  def perform(connection)
    setup_database_tasks!(connection.to_sym)
    remove_invalid_attributes!

    ActiveRecord::Base.establish_connection(connection.to_sym)
    ActiveRecord::Tasks::DatabaseTasks.load_schema(:ruby, schema_filename)
  end

  def remove_invalid_attributes!
    lines = read_schema_file

    File.open(schema_filename, "w:utf-8") do |file|
      lines.each do |line|
        remove_invalid_attributes_from_line!(line)

        file << line
      end
    end
  end

  def invalid_rules
    [
      #skip indexes as some are invalid and we won't have
      #large numbers of records in a test db
      [/.*add_index.*/, ""]
    ]
  end

  def remove_invalid_attributes_from_line!(line)
    invalid_rules.each do |find, replace|
      line.gsub!(find, replace)
    end

    line
  end
end


