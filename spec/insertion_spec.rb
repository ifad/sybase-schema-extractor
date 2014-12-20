describe Insertion do
  include SharedSpecSetup
  let(:insertion){ Insertion.new schema_filename }

  describe "#perform" do
    before do
      Extraction.perform(:production, schema_filename, tables_to_include)
    end

    it "inserts schema in postgres" do
      expect(adapter).to eq "Sybase"
      expect(tables.length).to be > 0

      insertion.perform("test")

      expect(adapter).to eq "PostgreSQL"

      expect(tables - ["schema_migrations"]).to match_array(tables_to_include)
    end
  end

  it "#remove_invalid_lines" do
    line = '   add_index :something'
    result = insertion.remove_invalid_attributes_from_line!(line)

    expect(result).to eq ''
  end
end
