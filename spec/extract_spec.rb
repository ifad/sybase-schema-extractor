describe SybaseSchemaExtractor do
  let(:extractor){ SybaseSchemaExtractor.new config }
  let(:config) { YAML.load "./config/database.yml" }
  let(:schema_filename) { "./tmp/schema.rb" }

  before do
    begin
      File.delete schema_filename
    rescue Errno::ENOENT
      nil
    end
  end

  it "extracts the schema" do
    extractor.perform(:dev_db, schema_filename)

    file = File.read(schema_filename)
    schema_section = "ActiveRecord::Schema.define(version: 0)"
    matching_length =  file[schema_section].length

    expect(matching_length).to eq schema_section.length
  end
end
