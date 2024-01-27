module Chats
  module App
    class GetChatParticipantDto < ApplicationReadStruct
      attribute :id, Types::String
      attribute :name, Types::String
      attribute :chat_participants, Types::Array.of(ChatParticipantDto)
    end
  end
end

