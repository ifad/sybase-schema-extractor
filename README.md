# SchemaTransfer

##example usage
```bash
git clone https://github.com/ifad/sybase-schema-extractor.git
cd sybase-schema-extractor
bundle install

./bin/transfer-schema ../my-project/config/database.yml production test ../my-project/tables.txt
```

```
bundle exec ruby bin/transfer-schema <config_filename> <from> <to> [file_with_list_of_tables_to_include]
  file_with_list_of_tables_to_include (separated by \n)
  from (source config block in the config file)
  to   (destination config block in the config file)

  e.g.
  bin/transfer-schema ./config/database.yml production test tables.txt
`

Where tables.txt is something like
#Export tables from other project

```ruby
#in a console

File.open("tables.txt", "w") do |file|
  Dir.glob("./app/models/**/*.rb").each{|f| require f }
    ActiveRecord::Base.descendants.map(&:table_name).each do |table_name|
      file << "#{table_name}\n"
    end
  end
end
```
