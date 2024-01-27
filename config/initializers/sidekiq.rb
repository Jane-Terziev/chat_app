require 'sidekiq/web'

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == [ENV.fetch('SIDEKIQ_USERNAME'), ENV.fetch('SIDEKIQ_PASSWORD')]
end