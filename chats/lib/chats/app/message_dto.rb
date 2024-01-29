require "unicode/emoji"

module Chats
  module App
    class MessageDto < ApplicationReadStruct
      attribute :id, Types::String
      attribute? :message, Types::String
      attribute :user_id, Types::String
      attribute :chat_id, Types::String
      attribute? :attachment_file, ::Chats::Domain::FileDto
      attribute :created_at, Types::DateTime

      def is_an_emoji?
        self.message.scan(Unicode::Emoji::REGEX).join('') == self.message && self.message.present?
      end
    end
  end
end
