RSpec.describe Extraction do
  include SharedSpecSetup
  let(:extraction){ Extraction.new schema_filename }

  let(:expected) {"ActiveRecord::Schema.define(version: 0)"}
  let(:matching_output_length) { schema[expected].length }


  describe "#extract" do
    it "extracts the schema" do
      extraction.perform(:production)

      expect(matching_output_length).to eq expected.length
    end
  end


  context "tweaking the schema" do
    let(:sample_schema) do
      strip_heredoc(<<-SCHEMA).split("\n")
        # encoding: UTF-8
        # This file is auto-generated from the current state of the database. Instead
        # ...
        # It's strongly recommended that you check this file into your version control system.

        ActiveRecord::Schema.define(version: 0) do

          create_table "tmp_delete_me", force: true do |t|
            t.datetime "SOME_COLUMN"
            t.string   "ANOTHER_COLUMN",          limit: 35
          end

          create_table "another_unused", id: false, force: true do |t|
            t.integer  "ODI_SESS_NO",             limit: 19
          end

          create_table "VALID_TABLE", force: true do |t|
            t.datetime "THIS_IS_THE_ONE",          null: false
            t.float    "WE_LOVE_THIS_COLUMN"
          end
        end
      SCHEMA
    end

    before do
      expect(extraction).to receive(:read_schema_file).
        and_return sample_schema
    end

    let(:extraction) do
      Extraction.new(schema_filename, ["VALID_TABLE"])
    end

    describe "#unused_tables" do
      it do
        result = extraction.unused_tables

        expect(result).to eq ["tmp_delete_me", "another_unused"]
      end
    end

    describe "#mark_tables_to_exclude!" do
      before do
        extraction.setup_database_tasks!(:production)
      end

      it do
        extraction.mark_tables_to_exclude!(:production)

        expect(ActiveRecord::SchemaDumper.ignore_tables).to eq ["tmp_delete_me", "another_unused"]
      end
    end
  end

  describe ".extract" do
    it "has a one-line API for minimal surface area in the executable" do
      Extraction.perform("production", schema_filename, tables_to_include)

      expect(matching_output_length).to eq expected.length
    end
  end
end
