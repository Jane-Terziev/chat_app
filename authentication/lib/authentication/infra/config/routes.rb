Rails.application.routes.draw do
  devise_for :users,
             class_name: 'Authentication::Domain::User',
             controllers: {
               registrations: "authentication/ui/registrations",
               sessions: "authentication/ui/sessions"
             }
end
