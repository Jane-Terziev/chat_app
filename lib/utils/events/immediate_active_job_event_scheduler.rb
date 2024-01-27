class ImmediateActiveJobEventScheduler < RailsEventStore::ActiveJobScheduler
  def call(klass, serialized_event)
    klass.perform_now(serialized_event)
  end
end
