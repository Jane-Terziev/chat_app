module Chats
  module Domain
    module ReadModel
      class ChatListView < ApplicationRecord
        self.table_name = 'chat_list_views'
        self.primary_key = :id

        def self.ransackable_attributes(auth_object = nil)
          %w[name]
        end
      end
    end
  end
end
