module Chats
  module App
    class GetChatDetailsDto < ApplicationReadStruct
      attribute :id, Types::String
      attribute :name, Types::String
      attribute :messages, Types::Array.of(MessageDto)
    end
  end
end

