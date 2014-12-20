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

  before do
    FileUtils.rm_rf "./tmp/schema.rb"
    ActiveRecord::SchemaDumper.ignore_tables = []
  end


  #don't memoize so we can re-read after changes
  def schema
    File.read(schema_filename) rescue nil
  end

  let(:insertion){ Insertion.new config_filename, schema_filename }

  describe "#perform" do
    before do
      Extraction.perform(config_filename, :production, schema_filename, include_table_file)
    end

    #don't memoize
    def tables
      ActiveRecord::Base.connection.tables.sort
    end

    it "inserts schema in postgres" do
      expect(ActiveRecord::Base.connection.adapter_name).to eq "Sybase"
      expect(tables.length).to be > 0

      insertion.perform("test")

      expect(ActiveRecord::Base.connection.adapter_name).to eq "PostgreSQL"

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
