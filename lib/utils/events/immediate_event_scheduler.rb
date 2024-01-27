require_relative 'async_thread_event_scheduler'

class ImmediateEventScheduler < AsyncThreadEventScheduler
  def initialize(event_deserializer:)
    self.event_deserializer = event_deserializer
  end

  def call(subscriber, event)
    deserialized = event_deserializer.load(event)
    sub = Optional.of(subscriber)
                  .filter { |it| Class === it }
                  .map(&:new)
                  .or_else(subscriber)
    sub.call(deserialized)
  end
end
