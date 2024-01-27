class ConstraintError < StandardError
  attr_accessor :validator

  def initialize(validator)
    self.validator = validator
  end
end
