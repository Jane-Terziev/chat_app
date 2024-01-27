require_relative 'application_struct'

class CommandSerializer < ActiveJob::Serializers::ObjectSerializer
  def serialize(command)
    YAML.dump(command)
  end

  def deserialize(command)
    YAML.load(command)
  end

  def serialize?(command)
    command.is_a? ApplicationStruct
  end
end
