describe Insertion do
  def config_filename
    "./config/database.yml"
  end

  def schema_filename
    "./tmp/schema.rb"
  end

  def include_table_file
    "config/include_tables.txt"
  end


  #don't memoize so we can re-read after changes
  def schema
    File.read(schema_filename) rescue nil
  end

  before(:all) do
    extract_schema!
  end

  def extract_schema!
    File.delete schema_filename rescue nil
    Extraction.perform(config_filename, :production, schema_filename, include_table_file)
  end

  let(:insertion){ Insertion.new config_filename, schema_filename }

  describe "#perform" do
    #don't memoize
    def tables
      ActiveRecord::Base.connection.tables.sort
    end

    it "inserts schema in postgres" do
      #ensure fresh schema
      extract_schema!

      expect(ActiveRecord::Base.connection.adapter_name).to eq "Sybase"
      expect(tables.length).to be > 0

      insertion.perform("test")

      expect(ActiveRecord::Base.connection.adapter_name).to eq "PostgreSQL"

      expected_tables = File.readlines(include_table_file).sort.map(&:chomp)
      expect(tables - ["schema_migrations"]).to match_array(expected_tables)
    end
  end

  describe "remove_invalid_attributes_from_line!" do
    it do
      line = 't.integer "row_id",  limit: 10, null: false'

      expect(insertion.remove_invalid_attributes_from_line!(line)).
        to eq 't.integer "row_id", null: false'
    end
  end

  describe "#remove_invalid_attributes!" do
    before do
      #ensure schema not already been cleaned up
      extract_schema!
    end
    context "sybase generates integers with limit of 9" do
      it "ignores this limit" do
        expect(schema).to match /integer.*limit: 9/

        insertion.remove_invalid_attributes!

        expect(schema).not_to match /integer.* limit: 9/
      end
    end
  end
end
