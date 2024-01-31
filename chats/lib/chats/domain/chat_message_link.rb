module Chats
  module Domain
    class ChatMessageLink < ApplicationRecord
      self.table_name = 'chat_message_links'

      belongs_to :message
    end
  end
end
