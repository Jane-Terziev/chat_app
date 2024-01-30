module Chats
  module Ui
    class ChatParticipantListListener < AsyncEventHandler
      include Import.active_job[chat_read_service: 'chats.chat_read_service']
      def call(event)
        send "broadcast_#{event.class.name.demodulize}", event
      end

      def broadcast_ChatParticipantAddedEvent(event)
        user_ids = event.chat_participant_user_ids - [event.current_user_id]
        chat_participants_dto = chat_read_service.get_active_chat_participants(event.chat_id)
        user_ids.each do |user_id|
          Turbo::StreamsChannel.broadcast_replace_to(
            [event.chat_id, user_id],
            target: 'chatParticipantList',
            partial: 'chats/ui/participants/participant_list',
            locals: { participants: chat_participants_dto, chat_id: event.chat_id, user_id: event.current_user_id }
          )
        end
      end

      def broadcast_ChatParticipantRemovedEvent(event)
        user_ids = event.chat_participant_user_ids - [event.current_user_id]
        chat_participants_dto = chat_read_service.get_active_chat_participants(event.chat_id)
        user_ids.each do |user_id|
          Turbo::StreamsChannel.broadcast_replace_to(
            [event.chat_id, user_id],
            target: 'chatParticipantList',
            partial: 'chats/ui/participants/participant_list',
            locals: { participants: chat_participants_dto, chat_id: event.chat_id, user_id: event.current_user_id }
          )
        end
      end
    end
  end
end
