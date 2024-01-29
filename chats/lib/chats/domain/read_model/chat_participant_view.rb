module Chats
  module Domain
    module ReadModel
      class ChatParticipantView < ApplicationRecord
        self.table_name = 'chat_participant_views'
        self.primary_key = :id
      end
    end
  end
end
