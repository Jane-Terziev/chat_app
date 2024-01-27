class ApplicationContract < Dry::Validation::Contract
  attr_accessor :errors, :params, :result

  def initialize(errors: {}, params: {}, result: nil)
    super()
    self.errors = errors
    self.params = params
    self.result = result
  end

  def self.command
    DryStructGenerator::StructGenerator.new.call(self)
  end

  register_macro(:email_format) do
    unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(value)
      key.failure('not a valid email')
    end
  end

  register_macro(:password_format) do
    unless /^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$/i.match?(value)
      key.failure('must contain 1 lower case letter, 1 upper case letter, 1 number, 1 special character and have a minimum length of 8')
    end
  end

  def to_h
    self.class.schema.rules.keys.inject({}) do |hash, key|
      hash.merge({ key => self.send(key) })
    end
  end
end
