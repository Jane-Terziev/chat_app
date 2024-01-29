module Chats
  module App
    module ReadModel
      class ChatParticipantDto < ApplicationReadStruct
        attribute :id, Types::String
        attribute :user_id, Types::String
        attribute :chat_id, Types::String
        attribute :first_name, Types::String
        attribute :last_name, Types::String
        attribute :status, ::Chats::Domain::ChatParticipant::STATUS
      end
    end
  end
end
