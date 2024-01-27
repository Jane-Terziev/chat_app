module Chats
  module Domain
    class Chat
      class ChatParticipantRemovedEvent < IntegrationEvent
        def chat_id
          data[:chat_id]
        end

        def removed_user_id
          data[:removed_user_id]
        end

        def chat_participant_user_ids
          data[:chat_participant_user_ids]
        end
      end
    end
  end
end