describe SybaseSchemaExtractor do
  let(:extractor){ SybaseSchemaExtractor.new config }
  let(:config) { YAML.load "./config/database.yml" }
  let(:schema_filename) { "./tmp/schema.rb" }
  let(:schema) { File.read(schema_filename) }

  before do
    begin
      File.delete schema_filename
    rescue Errno::ENOENT
      nil
    end
  end

  it "extracts the schema" do
    extractor.perform(:dev_db, schema_filename)

    expected = "ActiveRecord::Schema.define(version: 0)"
    length =  schema[expected].length

    expect(length).to eq expected.length
  end
end
