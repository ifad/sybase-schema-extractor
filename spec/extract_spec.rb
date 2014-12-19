describe SybaseSchemaExtractor do
  let(:extractor){ SybaseSchemaExtractor.new config_filename }
  let(:config_filename) { "./config/database.yml" }
  let(:schema_filename) { "./tmp/schema.rb" }
  let(:schema) { File.read(schema_filename) }

  let(:expected) {"ActiveRecord::Schema.define(version: 0)"}
  let(:matching_output_length) { schema[expected].length }

  before do
    File.delete schema_filename rescue nil
  end

  it "extracts the schema" do
    extractor.perform(:dev_db, schema_filename)

    expect(matching_output_length).to eq expected.length
  end

  it "has a one-line API for minimal surface area in the executable" do
    SybaseSchemaExtractor.perform(config_filename, "dev_db", schema_filename)

    expect(matching_output_length).to eq expected.length
  end

  it "has an executable" do
    `bin/extract-sybase-schema #{config_filename} dev_db #{schema_filename}`

    expect(matching_output_length).to eq expected.length
  end
end
