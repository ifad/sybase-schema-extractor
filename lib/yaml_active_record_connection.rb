module YamlActiveRecordConnection
  def self.establish!(filename)
    config = YAML.load(File.read(filename)).with_indifferent_access
    ActiveRecord::Base.configurations = config
  end
end
