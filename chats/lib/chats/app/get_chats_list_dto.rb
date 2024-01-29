module Chats
  module App
    class GetChatsListDto < ApplicationReadStruct
      attribute :id, Types::String
      attribute :name, Types::String
      attribute :last_message, Types::String
      attribute :unread_messages_count, Types::Integer
      attribute :last_message_timestamp, Types::DateTime

      def has_unread_messages?
        unread_messages_count > 0
      end
    end
  end
end

