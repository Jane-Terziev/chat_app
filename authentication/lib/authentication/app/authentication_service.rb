module Authentication
  module App
    class AuthenticationService < ApplicationService
      include Import[user_repository: 'authentication.user_repository']
      include ::Devise::Controllers::SignInOut

      def authenticate_user(command, warden)
        ActiveRecord::Base.transaction do
          user = user_repository.find_by(email: command.email)
          if user && user.valid_password?(command.password)
            warden.set_user(user, scope: :user)
          else
            raise Errors::InvalidCredentialsError.new
          end
        end
      end
    end
  end
end
