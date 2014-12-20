describe "extract binary" do
  include SharedSpecSetup

  it "has extracts the schema" do
    output = `bin/extract #{config_filename} production #{schema_filename} 2>&1`

    expect(output).to match /extracted to/
    expect(output).to match /#{schema_filename}/
  end
end
