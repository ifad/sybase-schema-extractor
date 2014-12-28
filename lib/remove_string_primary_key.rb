class RemoveStringPrimaryKey
  def self.perform(schema)
    new.perform(schema)
  end

  def perform(schema)
    new_schema = ""

    split_into_tables(schema).each do |t|
      if table_name = table_name_from_definition_body(t)

        if string_primary_key?(table_name)
          t = remove_pk_from_create_table_line(t)
          t = add_pk_after_table_definition(t, table_name)
        end
      end

      new_schema << t
    end

    new_schema
  end

  def split_into_tables(schema)
    schema.split(/\nend\n?/).map{|s| "#{s}\nend\n"}
  end

  def remove_pk_from_create_table_line(t)
    t.split("\n").map do |l|
      if l =~ /create_table.*primary_key/
        l.gsub! /create_table(.*), primary_key: "([^\"]*)"/, 'create_table\1'
      end
      l
    end.join("\n")
  end

  def add_pk_after_table_definition(t, table_name)
    "#{t}\nchange_column :#{table_name}, :#{primary_key(table_name)}, :string\n"
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
end

