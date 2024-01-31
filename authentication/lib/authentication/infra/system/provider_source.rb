Dry::System.register_provider_source(:authentication, group: :authentication) do
  prepare do
    register('authentication.user_repository') { Authentication::Domain::User }
    register('authentication.authentication_service') { Authentication::App::AuthenticationService.new }
    register('authentication.registration_service') { Authentication::App::RegistrationService.new }
  end
end

App::Container.register_provider(:authentication, from: :authentication)
App::Container.start(:authentication)

