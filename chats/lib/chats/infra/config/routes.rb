Rails.application.routes.draw do
  resources :chats, controller: "chats/ui/chats" do
    get 'acknowledge', to: "chats/ui/chats#acknowledge", as: 'acknowledge'

    resources :messages, controller: "chats/ui/messages"
    resources :participants, controller: "chats/ui/participants"
    delete 'leave_chat', to: 'chats/ui/chats#leave_chat', as: 'leave_chat'
  end
end
