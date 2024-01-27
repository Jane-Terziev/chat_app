module Chats
  module Domain
    class UnacknowledgedMessage < ApplicationRecord
      self.table_name = "unacknowledged_messages"

      belongs_to :message
    end
  end
end
