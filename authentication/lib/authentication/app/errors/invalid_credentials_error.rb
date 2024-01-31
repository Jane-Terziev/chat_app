module Authentication
  module App
    module Errors
      class InvalidCredentialsError < StandardError
        attr_accessor :message, :code, :status

        def initialize(message: 'Invalid Credentials', code: 'user_already_exists', status: 422)
          self.message = message
          self.code = code
          self.status = status
        end
      end
    end
  end
end
