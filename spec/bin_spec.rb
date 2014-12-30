RSpec.describe("executables", skip_db_cleaner: true) do
  include SharedSpecSetup
  before do
    #migrations don't work if we are still connected to the db
    ActiveRecord::Base.remove_connection
  end


  it "extracts the schema" do
    output = `bin/extract #{config_filename} production #{schema_filename} 2>&1`

    expect(output).to match(/extracted to/)
    expect(output).to match(/#{schema_filename}/)
  end

  it "transfers the schema" do
    output = `bin/transfer-schema #{config_filename} production test config/include_tables.txt 2>&1`

    expect(output).to match(/transferred schema from production to test/)
  end
end
