module Chats
  module App
    module ReadModel
      class ChatMessageLinkDto < ApplicationReadStruct
        attribute :id, Types::String
        attribute :message_id, Types::String
        attribute :link, Types::String
      end
    end
  end
end
