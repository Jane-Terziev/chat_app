module Authentication
  module Ui
    class RegistrationsController < ApplicationController
      include Import.inject[registration_service: 'authentication.registration_service']

      skip_before_action :authenticate_user!

      def new
        render :new, locals: { form: RegistrationValidator.new }
      end

      def create
        registration_service.register_user(
          validator.validate(registration_params, RegistrationValidator.new),
          request.env['warden']
        )
        redirect_to root_path, notice: 'Successfully signed in!'
      rescue ConstraintError => e
        render :new, locals: { form: e.validator }, status: 422
      rescue ::Authentication::App::Errors::UserAlreadyExistsError => e
        flash.now[:error] = [e.message]
        render :new, locals: { form: RegistrationValidator.new(params: registration_params) }, status: 422
      end

      private

      def registration_params
        params.require(:registration).to_unsafe_h
      end
    end
  end
end