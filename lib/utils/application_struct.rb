class ApplicationStruct < Dry::Struct
  transform_keys(&:to_sym)

  transform_types do |type|
    if type.default?
      type.constructor do |value|
        value.nil? ? Dry::Types::Undefined : value
      end
    else
      type
    end
  end

  def ==(other)
    return false unless other

    self.class == other.class && attributes == other.attributes
  end

  alias eql? ==

  def hash
    attributes.hash
  end
end
