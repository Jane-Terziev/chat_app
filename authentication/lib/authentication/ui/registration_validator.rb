module Authentication
  module Ui
    class RegistrationValidator < ApplicationContract
      params do
        required(:email).value(Types::StrippedString, :filled?)
        required(:password).value(Types::StrippedString, :filled?)
        required(:password_confirmation).value(Types::StrippedString, :filled?)
        required(:first_name).value(Types::StrippedString, :filled?)
        required(:last_name).value(Types::StrippedString, :filled?)
      end

      rule(:email).validate(:email_format)
      rule(:password).validate(:password_format)

      rule(:password, :password_confirmation) do
        if values[:password] != values[:password_confirmation]
          key(:password).failure('must match with password confirmation')
          key(:password_confirmation).failure('must match with password')
        end
      end
    end
  end
end