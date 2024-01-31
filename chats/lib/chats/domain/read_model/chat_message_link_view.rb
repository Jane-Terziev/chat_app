module Chats
  module Domain
    module ReadModel
      class ChatMessageLinkView < ApplicationRecord
        self.table_name = "chat_message_link_views"
      end
    end
  end
end
