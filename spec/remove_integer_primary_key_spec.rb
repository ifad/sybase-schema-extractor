RSpec.describe RemoveIntegerPrimaryKey do
  let(:removal) { RemoveIntegerPrimaryKey.new }
  let(:country) do
    kw! <<-FILE
      create_table "t_d_country", primary_key: "country_id", force: true do |t|
      end
    FILE
  end
  let(:schema) do
    kw! <<-FILE
    ARHeaderStuff do
      create_table "t_d_country_codes", force: true do |t|
      end
      #{country}
    end
    FILE
  end

  def read_primary_key_info_from_production!
    ActiveRecord::Base.establish_connection :production
  end

  before do
    read_primary_key_info_from_production!
  end

  describe "#remove_pk_from_create_table_line" do
    it do
      expect(removal.remove_pk_from_create_table_line(country, "country_id")).to eq kw!(<<-TABLE)
        create_table "t_d_country", force: true do |t|
        end
      TABLE
    end
  end
  describe "#generate_from" do
    it "removes string primary keys and retains tables without string primary keys" do
      expect(removal.generate_from(schema)).to eq kw!(<<-TABLE)
        ARHeaderStuff do
          create_table "t_d_country_codes", force: true do |t|
          end
          create_table "t_d_country", force: true do |t|
          end
        end
      TABLE
    end
  end
end

