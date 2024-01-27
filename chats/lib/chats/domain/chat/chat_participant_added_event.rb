module Chats
  module Domain
    class Chat
      class ChatParticipantAddedEvent < IntegrationEvent
        def chat_id
          data[:chat_id]
        end

        def chat_participant_user_id
          data[:chat_participant_user_id]
        end
      end
    end
  end
end