module Chats
  module Ui
    class ChatMessageListListener < AsyncEventHandler
      include Import.active_job[message_list_view_repository: 'chats.message_list_view_repository']

      def call(event)
        send "broadcast_#{event.class.name.demodulize}", event
      end

      private

      def broadcast_MessageSentEvent(event)
        user_ids = event.chat_participant_user_ids - [event.current_user_id]
        message_list_view_repository.where(id: event.message_id, user_id: user_ids).each do |message|
          Turbo::StreamsChannel.broadcast_append_to(
            [event.chat_id, message.user_id],
            target: 'messageContainer',
            partial: 'chats/ui/messages/message_list_item',
            locals: {
              message: ::DryObjectMapper::Mapper.call(message, ::Chats::App::MessageDto),
              user_id: event.current_user_id,
              should_scroll: true,
              acknowledge: true
            }
          )
        end
      end

      def broadcast_MessageRemovedEvent(event)
        user_ids = event.chat_participant_user_ids - [event.current_user_id]
        user_ids.each do |user_id|
          Turbo::StreamsChannel.broadcast_remove_to([event.chat_id, user_id], target: event.message_id)
        end
      end

      def broadcast_ChatParticipantRemovedEvent(event)
        return if event.removed_user_id == event.current_user_id

        Turbo::StreamsChannel.broadcast_replace_to(
          [event.chat_id, event.removed_user_id],
          target: 'flash',
          partial: 'shared/flash',
          locals: { flash: { error: ['You have been removed from the chat!'] } }
        )

        Turbo::StreamsChannel.broadcast_remove_to(
          [event.chat_id, event.removed_user_id],
          target: 'chatMessageContainer'
        )
      end
    end
  end
end
