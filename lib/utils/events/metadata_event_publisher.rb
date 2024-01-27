require 'utils/optional'

class MetadataEventPublisher
  attr_accessor :client, :current_user_repository

  def initialize(
    client: App::Container.resolve('events.client'),
    current_user_repository: App::Container.resolve('current_user_repository')
  )
    self.client = client
    self.current_user_repository = current_user_repository
  end

  def publish(event)
    user_id = Optional.of_nullable(current_user_repository.authenticated_identity).map(&:id).or_else(nil)
    client.with_metadata({ user_id: user_id, registered_at: DateTime.now }) do
      client.publish(event)
    end
  end

  def publish_all(events)
    events.each { |event| publish(event) }
    events.clear
  end

  def subscribe(subscriber, to:)
    client.subscribe(subscriber, to: to)
  end

  def mapper
    client.send(:mapper)
  end

  def deserialize(serialized_event, serializer)
    serializer.load(serialized_event)
  end
end
