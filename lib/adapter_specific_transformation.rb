class AdapterSpecificTransformation
  def self.from_file(from, to, filename)
    perform(from, to, File.read(filename))
  end

  def self.perform(from, to, schema)
    new(from, to, schema).perform
  end

  def initialize(from, to, schema)
    @schema = kill_leading_whitespace! schema
    @from = from
    @to   = to
  end

  def perform
    if from_sybase? && to_postgres?
      ActiveRecord::Base.establish_connection(@from.to_sym)
      @schema = RemoveStringPrimaryKey.perform(@schema)
    end

    @schema
  end

  private

  #It's easier to compare/test ruby code without leading whitespace.
  #ideally we'd handle this nicely but the
  #schema files are only normally present during a schema extraction/insertion
  def kill_leading_whitespace!(s)
    s.gsub!(/^\s*/,"")
  end

  def from_sybase?
    from_adapter == "sybase"
  end

  def to_postgres?
    to_adapter == "postgresql"
  end

  def adapter(connection)
    ActiveRecord::Base.configurations[connection][:adapter]
  end

  def to_adapter
    adapter @to
  end

  def from_adapter
    adapter @from
  end
end
