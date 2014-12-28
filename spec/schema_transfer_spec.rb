  #these specs whilst as generic as possilbe dependent on a specific
  #config/database.yml not in git
  #
  #Currently targetting loading a schema from a sybase install over which we
  #have no control and loading into a postgres db for testing which we can
  #control and create records/specs/factories etc.
  #
  #They expect something like:
  #
  #production:
  #  adapter: sybase
  #  credentials: go
  #  in: here
  #
  #test:
  #  adapter: pg
  #  credentials: go
  #  in: here
  #
RSpec.describe SchemaTransfer do
  include SharedSpecSetup
  let(:transfer) { SchemaTransfer.new(
    from: :production,
    to: :test,
    tables: tables_to_include)}

  before do
    #sanity checks
    with_connection(:production)  { expect(adapter).to eq "Sybase" }
    with_connection(:test)        do
      expect(adapter).to eq "PostgreSQL"

      ActiveRecord::Base.connection.tap do |c|
        c.tables.each do |t|
          c.drop_table t
        end
      end
    end
  end

  it do
    with_connection(:production) do
      @prod_table_count = tables.length
      expect(@prod_table_count).to be > 0
    end
    with_connection(:test) do
      expect(tables.length).to eq 0
    end

    transfer.perform

    with_connection(:test) do
      table_count = (tables - ["schema_migrations"]).length
      expect(table_count).to eq tables_to_include.length
    end
  end
end
