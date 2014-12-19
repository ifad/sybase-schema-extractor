require "active_record"
require "active_record/connection_adapters/sybase_adapter"
require "yaml"
require "./lib/shared"
require "./lib/extraction"
require "./lib/insertion"

class SchemaTrasnfer
  def perform
    Extraction.perform()
  end

end

