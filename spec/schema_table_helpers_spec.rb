RSpec.describe SchemaTableHelpers do
  before do
    YamlActiveRecordConnection.establish!("./config/database.yml")
    ActiveRecord::Base.establish_connection :production
  end
  let(:removal) { RemoveIntegerPrimaryKey.new }
  let(:eggs) {
    kw! <<-FILE
      create_table "eggs", force: true do |t|
        t.string :cheese
      end
    FILE
  }
  let(:countries) do
    kw! <<-FILE
      create_table "t_d_country", primary_key: "country_id", force: true do |t|
      end
    FILE
  end

  describe "#string_primary_key?" do
    it do
      expect(removal.string_primary_key?("t_d_country")).to eq true
    end
  end

  describe "table_name_from_definition_body" do
    it do
      expect(removal.table_name_from_definition_body(countries)).to eq "t_d_country"
      expect(removal.table_name_from_definition_body("no match")).to eq nil
    end
  end


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
end


