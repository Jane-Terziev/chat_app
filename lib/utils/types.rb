module Types
  include Dry.Types()

  StrippedString = Types::String.constructor(&:strip)
  DateTime = Types::DateTime.constructor(&:to_datetime)
  Date = Types::Date.constructor(&:to_date)
  Email = Types::String.constructor(&:strip).constructor(&:downcase).constrained(
    format: /\A[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*\z/i
  )
  # contains at least a lowercase letter, an uppercase, a digit, and has 6+ chars
  Password = Types::String.constructor(&:strip).constrained(
    format: /^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])[A-Za-z0-9]{6,}$/
  )
end