require "unicode/emoji"

module Chats
  module App
    class MessageDto < ApplicationReadStruct
      attribute :id, Types::String
      attribute :message, Types::String
      attribute :chat_participant, ChatParticipantDto
      attribute :created_at, Types::DateTime
      attribute? :attachment_files, Types::Array.of(::Chats::Domain::FileDto)

      def is_an_emoji?
        self.message.scan(Unicode::Emoji::REGEX).join('') == self.message && self.message.present?
      end
    end
  end
end
