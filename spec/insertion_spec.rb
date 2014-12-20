describe Insertion do
  include SharedSpecSetup
  let(:insertion){ Insertion.new schema_filename }

  describe "#perform" do
    before do
      Extraction.perform(:production, schema_filename, include_table_file)
    end

    it "inserts schema in postgres" do
      expect(adapter).to eq "Sybase"
      expect(tables.length).to be > 0

      insertion.perform("test")

      expect(adapter).to eq "PostgreSQL"

      expected_tables = File.readlines(include_table_file).sort.map(&:chomp)
      expect(tables - ["schema_migrations"]).to match_array(expected_tables)
    end
  end

  it "#remove_invalid_lines" do
    line = '   add_index :something'
    result = insertion.remove_invalid_attributes_from_line!(line)

    expect(result).to eq ''
  end
end
