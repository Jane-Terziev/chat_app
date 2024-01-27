module Chats
  module Domain
    class Chat
      class MessageSentEvent < IntegrationEvent
        def chat_id
          data[:chat_id]
        end

        def message_id
          data[:message_id]
        end
      end
    end
  end
end