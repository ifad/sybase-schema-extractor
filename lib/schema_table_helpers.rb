module SchemaTableHelpers
  def each_table(schema)
    return enum_for(__method__, schema) unless block_given?

    split_into_tables(schema).each do |table_definition|
      if table_name = table_name_from_definition_body(table_definition)
        yield table_name, table_definition, primary_key(table_name), string_primary_key?(table_name)
      end
    end
  end

  def with_file(filename)
    schema = File.read(filename)

    File.open(filename, "w:utf-8") do |f|
      yield schema, f
    end
  end

  def split_into_tables(schema)
    schema.split(/\nend\n?/).map{|s| "#{s}\nend\n"}
  end

  def table_name_from_definition_body(t)
    t.match(/create_table "([^\"]+)"/)[1] rescue nil
  end

  def string_primary_key?(table_name)
    column = ActiveRecord::Base.connection.
      columns(table_name).
      find{|c| c.name == primary_key(table_name)}

    if column
      column.type == :string
    end
  end

  def primary_key(table_name)
    ActiveRecord::Base.connection.primary_key table_name
  end

  private

  #It's easier to compare/test ruby code without leading whitespace.
  #ideally we'd handle this nicely but the
  #schema files are only normally present during a schema extraction/insertion
  def kill_leading_whitespace!(s)
    if s.is_a?(Array)
      s.map{|i| kill_leading_whitespace!(i)}
    else
      s.gsub!(/^ */,"").chomp
      s.gsub!(/\A\n/,"")
      s.gsub!(/\n\z/,"")
      s
    end
  end
end
