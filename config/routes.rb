require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "chats/ui/chats#index"
  post 'rails/active_storage/direct_uploads', to: 'active_storage/direct_uploads#create'
  delete 'rails/active_storage/direct_uploads', to: 'active_storage/direct_uploads#destroy'
end
