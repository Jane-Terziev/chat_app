class ContractValidator
  def validate(input_hash, validator, options = {})
    result = validator.call(input_hash)
    validator.result = result
    validator.params = result.to_h.with_indifferent_access

    return validator.class.command.new(result.to_h.merge(options)) if result.success?

    validator.errors = result.errors.to_h.with_indifferent_access
    raise ConstraintError.new(validator)
  end
end
