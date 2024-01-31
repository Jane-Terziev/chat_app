module Authentication
  module App
    class RegistrationService < ApplicationService
      include Import[
                user_repository: 'authentication.user_repository',
                authentication_service: 'authentication.authentication_service'
              ]
      include ::Devise::Controllers::SignInOut

      def register_user(command, warden)
        user = ActiveRecord::Base.transaction do
          raise Errors::UserAlreadyExistsError.new if user_repository.exists?(email: command.email)

          user = user_repository.create_new(
            email: command.email,
            password: command.password,
            first_name: command.first_name,
            last_name: command.last_name
          )

          user_repository.save!(user)
        end

        warden.set_user(user, scope: :user)
      end
    end
  end
end
