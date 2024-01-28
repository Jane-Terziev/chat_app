class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.save!(record)
    record.tap(&:save!)
  end

  def self.delete!(record)
    record.tap(&:destroy!)
  end
end
