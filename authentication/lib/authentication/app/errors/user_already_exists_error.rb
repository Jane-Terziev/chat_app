module Authentication
  module App
    module Errors
      class UserAlreadyExistsError < StandardError
        attr_accessor :message, :code, :status

        def initialize(message: 'A user with that email already exists!', code: 'user_already_exists', status: 422)
          self.message = message
          self.code = code
          self.status = status
        end
      end
    end
  end
end
