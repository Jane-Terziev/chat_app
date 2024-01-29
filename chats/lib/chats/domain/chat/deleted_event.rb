module Chats
  module Domain
    class Chat
      class DeletedEvent < IntegrationEvent
        def chat_id
          data[:chat_id]
        end

        def chat_participant_user_ids
          data[:chat_participant_user_ids]
        end
      end
    end
  end
end