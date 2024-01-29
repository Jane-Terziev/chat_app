Rails.application.routes.draw do
  resources :chats, controller: "chats/ui/chats" do
    get 'acknowledge', to: "chats/ui/chats#acknowledge", as: 'acknowledge'
    resources :messages, controller: "chats/ui/messages"
    get 'load_more', to: 'chats/ui/messages#load_more', as: 'messages_load_more'
    resources :participants, controller: "chats/ui/participants"
    delete 'leave_chat', to: 'chats/ui/chats#leave_chat', as: 'leave_chat'
    resources :images, controller: "chats/ui/chat_images"
  end
end
