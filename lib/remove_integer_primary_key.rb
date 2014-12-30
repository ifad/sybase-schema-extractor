class RemoveIntegerPrimaryKey
  include SchemaTableHelpers

  def self.perform(filename)
    new.perform(filename)
  end

  def perform(filename)
    with_file(filename) do |original, f|
      f << generate_from(original)
    end
  end

  def generate_from(schema)
    schema = kill_leading_whitespace!(schema)
    new_schema = ""

    first_table = true
    each_table(schema) do |_, table_def, pk, _|
      new_schema << "\n" unless first_table
      new_schema << remove_pk_from_create_table_line(table_def, pk)
      first_table = false
    end

    new_schema << "\nend"
  end

  def remove_pk_from_create_table_line(t, pk)
    t.split("\n").map do |l|
      if l =~ /create_table.*primary_key/
        l.gsub! /create_table(.*), primary_key: "#{pk}"/, 'create_table\1'
      end
      l
    end.join("\n")
  end
end
