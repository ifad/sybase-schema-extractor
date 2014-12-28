RSpec.describe AdapterSpecificTransformation do
  #based on
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
    s.gsub!(/^\s*/,"")
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

  let(:schema) do
    kw! <<-FILE
      #{countries}

      #{eggs}
    FILE
  end

  before do
    YamlActiveRecordConnection.establish!("./config/database.yml")
  end


  let(:transform_countries) do
    kw! <<-FILE
      create_table "t_d_country", force: true do |t|
      end
      change_column :t_d_country, :country_id, :string
    FILE
  end

  let(:expected_tranform) do
    kw! <<-FILE
      #{transform_countries}

      #{eggs}
    FILE
  end

  describe ".perform" do
    it do
      transformed = AdapterSpecificTransformation.perform :production, :test, schema

      expect(transformed).to eq expected_tranform
    end
  end
end
