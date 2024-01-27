class Optional
  def self.of_nullable(value)
    new(value)
  end

  def self.of(value)
    raise ArgumentError, 'value is nil' if value.nil?
    new(value)
  end

  def self.empty
    new(nil)
  end

  def initialize(value)
    self.value = value
  end

  def get
    if value.nil?
      raise ArgumentError, 'no value present'
    else
      value
    end
  end

  def present?
    !value.nil?
  end

  def if_present(&consumer)
    consumer.call(value) if present?
  end

  def and_then(&consumer)
    return self unless present?

    consumer.call(value)
    self
  end

  def filter(&predicate)
    return self unless present?

    predicate.call(value) ? self : Optional.empty
  end

  def map(&mapper)
    return self unless present?

    Optional.of_nullable(mapper.call(value))
  end

  def flat_map(&mapper)
    return self unless present?

    mapper.call(value)
  end

  def or(&supplier)
    present? ? self : self.class.of_nullable(supplier.call)
  end

  def or_else(other)
    present? ? value : other
  end

  def or_else_get(&supplier)
    present? ? value : supplier.call
  end

  def or_else_raise(&error_supplier)
    if present?
      value
    else
      raise error_supplier.call
    end
  end

  def as_json(_options = {})
    present? ? value.as_json : nil
  end

  def ==(other)
    other.filter { |it| it == value }.present?
  end

  alias eql? ==

  def hash
    value.hash
  end

  private

  attr_accessor :value
end
