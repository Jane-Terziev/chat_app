module Chats
  module Domain
    module ReadModel
      class ChatListView < ApplicationRecord
        self.table_name = 'chat_list_views'
        self.primary_key = :id
      end
    end
  end
end
