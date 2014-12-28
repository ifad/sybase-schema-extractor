class AdapterSpecificTransformation
  def self.from_file(from, to, filename)
    perform(from, to, File.read(filename))
  end

  def self.perform(from, to, schema)
    new(from, to, schema).perform
  end

  def initialize(from, to, schema)
    @schema = schema
    @from = from
    @to   = to
  end

  def perform
    if from_sybase? && to_postgres?
      ActiveRecord::Base.establish_connection(@from.to_sym)
      @schema = EnableStringPrimaryKey.perform(@schema)
    end

    @schema
  end

  private

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
