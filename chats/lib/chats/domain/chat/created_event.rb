module Chats
  module Domain
    class Chat
      class CreatedEvent < IntegrationEvent
        def chat_id
          data[:chat_id]
        end

        def participant_user_ids
          data[:participant_user_ids]
        end
      end
    end
  end
end