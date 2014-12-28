RSpec.describe RemoveStringPrimaryKey do
  #http://stackoverflow.com/questions/1200568/using-rails-how-can-i-set-my-primary-key-to-not-be-an-integer-typed-column/15297616#15297616
  let(:eggs) {
    kw! <<-FILE
      create_table "eggs", force: true do |t|
        t.string :cheese
      end
    FILE
  }
  #It's easier to compare/test ruby code without leading whitespace.
  #ideally we'd handle this nicely but the
  #schema files are only normally present during a schema extraction/insertion
  def kill_leading_whitespace!(s)
    if s.is_a?(Array)
      s.map{|i| kill_leading_whitespace!(i)}
    else
      s.gsub!(/^ */,"").chomp
      s.gsub!(/\A\n/,"")
      s.gsub!(/\n\z/,"")
      s
    end
  end

  def kw!(s)
    kill_leading_whitespace!(s)
  end

  let(:countries) do
    kw! <<-FILE
      create_table "t_d_country", primary_key: "country_id", force: true do |t|
      end
    FILE
  end

  let(:removal) { RemoveStringPrimaryKey.new }

  describe "#split_into_tables" do
    it do
      result = removal.split_into_tables kw! <<-FILE
        #{countries}

        #{eggs}
      FILE

      result = kw!(result)
      expect(result[0]).to eq countries
      expect(result[1]).to eq eggs
    end
  end

  context "reading from the db" do
    before do
      YamlActiveRecordConnection.establish!("./config/database.yml")
      ActiveRecord::Base.establish_connection :production
    end

    describe "#string_primary_key?" do
      it do
        expect(removal.string_primary_key?("t_d_country")).to eq true
      end
    end

    describe "#add_pk_after_table_definition" do
      it do
        expect(removal.add_pk_after_table_definition(countries, "t_d_country")).to eq kw!(<<-TABLE)
          create_table "t_d_country", primary_key: "country_id", force: true do |t|
          end
          change_column :t_d_country, :country_id, :string

        TABLE
      end
    end

  end

  describe "table_name_from_definition_body" do
    it do
      expect(removal.table_name_from_definition_body(countries)).to eq "t_d_country"
      expect(removal.table_name_from_definition_body("no match")).to eq nil
    end
  end

  describe "#remove_pk_from_create_table_line" do
    it do
      expect(removal.remove_pk_from_create_table_line(countries)).to eq kw!(<<-TABLE)
          create_table "t_d_country", force: true do |t|
          end
      TABLE
    end
  end
end

