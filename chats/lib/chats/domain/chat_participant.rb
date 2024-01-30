module Chats
  module Domain
    class ChatParticipant < ApplicationRecord
      self.table_name = "chat_participants"

      belongs_to :chat
      belongs_to :user
      has_many :messages, autosave: true, dependent: :destroy
      has_many :unacknowledged_messages, through: :messages

      STATUS = Types::String.enum('active', 'removed')

      def self.create_new(id: SecureRandom.uuid, user_id:, status: STATUS['active'])
        new(id: id, user_id: user_id, status: status)
      end

      def first_name
        user.first_name
      end

      def last_name
        user.last_name
      end

      def is_removed?
        self.status == STATUS['removed']
      end
    end
  end
end