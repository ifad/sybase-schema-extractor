class ExecuteStringPrimaryKeyMigrations
  include SchemaTableHelpers

  def self.perform(filename, from, to)
    new(filename, from, to).perform
  end

  attr_reader :schema

  def initialize(filename, from, to)
    @from, @to = from, to

    with_file(filename) do |schema_contents, _|
      @schema = schema_contents
    end
  end

  def perform
    eval generate!

    ActiveRecord::Base.establish_connection(@to.to_sym)
    CreateStringPrimaryKeyMigrations.migrate(:up)
  end

  def generate!
    migrations = "class CreateStringPrimaryKeyMigrations < ActiveRecord::Migration"
    migrations << "\n  def up"

    primary_key_migrations.each do |m|
      migrations << "\n    #{m}"
    end

    migrations << "\n  end"
    migrations << "\nend"
  end

  def primary_key_migrations
    ActiveRecord::Base.establish_connection(@from.to_sym)

    each_table(schema).map do |table_name, _, pk, is_string_pk|
      "add_column :#{table_name}, :#{pk}, :string" if is_string_pk
    end.compact
  end
end
