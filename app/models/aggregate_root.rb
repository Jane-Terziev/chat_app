class AggregateRoot < ApplicationRecord
  self.abstract_class = true

  def domain_events
    @domain_events ||= []
  end

  def clear_domain_events
    domain_events.clear
  end

  def apply_event(event)
    domain_events << event
    self.updated_at = DateTime.now
  end

  attr_writer :domain_events
end
