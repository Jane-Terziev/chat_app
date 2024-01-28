module Chats
  module Ui
    class ChatListListener < AsyncEventHandler
      include Import.active_job[chat_repository: 'chats.chat_repository']

      def call(event)
        send "broadcast_#{event.class.name.demodulize}", event
      end

      private

      def broadcast_CreatedEvent(event)
        chat = chat_repository.find(event.chat_id)
        chat.chat_participants.each do |participant|
          next if participant.user_id == event.current_user_id

          Turbo::StreamsChannel.broadcast_prepend_to(
            ['chats_list', participant.user_id],
            target: 'chats',
            partial: 'chats/ui/chats/chat_list_item',
            locals: {
              chat: ::DryObjectMapper::Mapper.call(
                chat,
                ::Chats::App::GetChatsListDto,
                { unread_messages: chat.unread_messages(participant.user_id) }
              ),
              move_to_top: false
            }
          )
        end
      end

      def broadcast_MessageSentEvent(event)
        chat = chat_repository.find(event.chat_id)
        chat.chat_participants.each do |participant|
          next if participant.user_id == event.current_user_id
          broadcast_replace_stream(chat, participant, true)
        end
      end

      def broadcast_MessageRemovedEvent(event)
        chat = chat_repository.find(event.chat_id)
        chat.chat_participants.each do |participant|
          next if participant.user_id == event.current_user_id
          broadcast_replace_stream(chat, participant, false)
        end
      end

      def broadcast_DeletedEvent(event)
        event.participant_user_ids.each do |user_id|
          next if user_id == event.current_user_id
          Turbo::StreamsChannel.broadcast_remove_to(['chats_list', user_id], target: event.chat_id)
        end
      end

      def broadcast_ChatParticipantAddedEvent(event)
        chat = chat_repository.find(event.chat_id)
        Turbo::StreamsChannel.broadcast_prepend_to(
          ['chats_list', event.chat_participant_user_id],
          target: 'chats',
          partial: 'chats/ui/chats/chat_list_item',
          locals: {
            chat: ::DryObjectMapper::Mapper.call(chat, ::Chats::App::GetChatsListDto, { unread_messages: 0 }),
            move_to_top: false
          }
        )

        Turbo::StreamsChannel.broadcast_replace_to(
          event.chat_participant_user_id,
          target: 'flash',
          partial: 'shared/flash',
          locals: { flash: { success: ['You have been added to a chat!']} }
        )
      end

      def broadcast_ChatParticipantRemovedEvent(event)
        return if event.removed_user_id == event.current_user_id
        Turbo::StreamsChannel.broadcast_remove_to(['chats_list', event.removed_user_id], target: event.chat_id)
      end

      def broadcast_replace_stream(chat, participant, move_to_top)
        Turbo::StreamsChannel.broadcast_replace_to(
          ['chats_list', participant.user_id],
          target: chat.id,
          partial: 'chats/ui/chats/chat_list_item',
          locals: {
            chat: ::DryObjectMapper::Mapper.call(
              chat,
              ::Chats::App::GetChatsListDto,
              { unread_messages: chat.unread_messages(participant.user_id) }
            ),
            move_to_top: move_to_top
          }
        )
      end
    end
  end
end
