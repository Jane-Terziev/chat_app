module Chats
  module Ui
    class MessageListQuery < ListQuery
      attribute :chat_id, Types::String
    end
  end
end
