module Chats
  module Domain
    class ChatParticipant < ApplicationRecord
      self.table_name = "chat_participants"

      belongs_to :chat
      has_many :messages, autosave: true, dependent: :destroy
      has_many :unacknowledged_messages, through: :messages
    end
  end
end