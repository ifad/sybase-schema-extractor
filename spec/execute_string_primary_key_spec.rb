RSpec.describe ExecuteStringPrimaryKeyMigrations do
  context "specific database coupled tests" do
    let(:schema) do
      <<-SCHEMA
        ActiveRecord::Schema.define(version: 0) do
          create_table "t_d_country", force: true do |t|
          end
        end
      SCHEMA
    end

    let(:execution) { ExecuteStringPrimaryKeyMigrations.new(filename, :production, :test) }

    let(:filename) { "tmp/schema.rb" }

    describe "#primary_key_migrations" do
      it do
        allow(execution).to receive(:schema).and_return schema
        expect(execution.primary_key_migrations).
          to eq ["add_column :t_d_country, :country_id, :string"]
      end
    end

    def import_schema
      #It's a shame to depend on other classes for test
      #setup but seems like the easiest way to ensure we
      #have a clean setup database
      #
      #As long as Insertion tests are green
      #we can test ExecuteStringPrimaryKeyMigrations
      insertion = Insertion.new(filename)
      allow(insertion).to receive(:read_schema_file).and_return schema.split("\n")
      insertion.perform(:test)
    end

    describe "#perform", skip_db_cleaner: true do
      before do
        drop_db(:test)
        import_schema
      end

      it do
        execution.perform

        class Country < ActiveRecord::Base
          self.table_name = "t_d_country"
        end

        #check we can use the string primary key
        Country.create! country_id: "egg"
        expect(Country.first.country_id).to eq "egg"
      end
    end
  end
end

