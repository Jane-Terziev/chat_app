module Chats
  module App
    class ChatParticipantDto < ApplicationReadStruct
      attribute :id, Types::String
      attribute :user_id, Types::String
      attribute :chat_id, Types::String
      attribute :first_name, Types::String
      attribute :last_name, Types::String
    end
  end
end
