require 'utils/optional'

class AsyncThreadEventScheduler
  def initialize(job_scheduler: nil, event_deserializer:)
    self.job_scheduler      = job_scheduler
    self.event_deserializer = event_deserializer
  end

  def call(subscriber, event)
    deserialized = event_deserializer.load(event)
    sub = Optional.of(subscriber)
            .filter { |it| Class === it }
            .map(&:new)
            .or_else(subscriber)
    job_scheduler.schedule(-> { sub.call(deserialized) })
  end

  def verify(subscriber)
    (Class === subscriber && subscriber < AsyncThreadEventHandler) || (Method === subscriber)
  end

  private

  attr_accessor :job_scheduler, :event_deserializer
end
