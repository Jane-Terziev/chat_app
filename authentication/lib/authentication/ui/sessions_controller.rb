module Authentication
  module Ui
    class SessionsController < ApplicationController
      include Import.inject[
                validator: 'contract_validator',
                authentication_service: 'authentication.authentication_service'
              ]

      skip_before_action :authenticate_user!

      def new
        render :new, locals: { form: SessionValidator.new }
      end

      def create
        authentication_service.authenticate_user(
          validator.validate(session_params, SessionValidator.new),
          request.env['warden']
        )
        redirect_to root_path, notice: 'Successfully signed in!'
      rescue ConstraintError => e
        render :new, locals: { form: e.validator }, status: 422
      rescue ::Authentication::App::Errors::InvalidCredentialsError => e
        flash.now[:error] = [e.message]
        render :new, locals: { form: SessionValidator.new(params: session_params) }, status: 422
      end

      def destroy
        sign_out(current_user)
        redirect_to user_session_path
      end

      private

      def session_params
        params.require(:session).to_unsafe_h
      end
    end
  end
end
