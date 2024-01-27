module Chats
  module Ui
    class ChatMessageListListener < AsyncEventHandler
      include Import.active_job[chat_repository: 'chats.chat_repository']

      def call(event)
        send "broadcast_#{event.class.name.demodulize}", event
      end

      private

      def broadcast_MessageSentEvent(event)
        chat = chat_repository.includes(chat_participants: { messages: :unacknowledged_messages }).find(event.chat_id)
        chat.chat_participants.each do |participant|
          next if participant.user_id == event.current_user_id

          Turbo::StreamsChannel.broadcast_append_to(
            [chat.id, participant.user_id],
            target: 'messageContainer',
            partial: 'chats/ui/messages/message_item',
            locals: {
              message: ::DryObjectMapper::Mapper.call(
                chat.messages.find {|it| it.id == event.message_id },
                ::Chats::App::MessageDto
              ),
              user_id: participant.user_id,
              should_scroll: true,
              acknowledge: true
            }
          )
        end
      end

      def broadcast_MessageRemovedEvent(event)
        event.participant_user_ids.each do |user_id|
          Turbo::StreamsChannel.broadcast_remove_to(
            [event.chat_id, user_id],
            target: event.message_id
          )
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
