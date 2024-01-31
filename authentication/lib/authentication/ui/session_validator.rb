module Authentication
  module Ui
    class SessionValidator < ApplicationContract
      params do
        required(:email).value(Types::StrippedString, :filled?)
        required(:password).value(Types::StrippedString, :filled?)
      end

      rule(:email).validate(:email_format)
      rule(:password).validate(:password_format)
    end
  end
end