module ApplicationHelper
  include Pagy::Frontend

  def show_error(validator, keys)
    return unless validator.errors
    keys = [keys] unless keys.is_a?(Array)
    field_name = keys.last
    if validator.errors.any?
      result = find_value(validator.errors, keys)
      return "#{field_name.to_s.humanize} #{result.join(', ')}" unless result.blank?
    end
  end

  def find_value(hash, keys)
    result = hash
    keys.each do |key|
      if result.is_a?(Hash) && result.key?(key)
        result = result[key]
      elsif result.is_a?(Array)
        result = result.map { |item| item.is_a?(Hash) ? item[key] : nil }.compact
        result = result.first if result.length == 1 # If there's only one element in the array
      else
        return nil
      end
    end
    result
  end

  def invalid?(validator, keys)
    if show_error(validator, keys)
      'invalid'
    else
      ''
    end
  end
end
