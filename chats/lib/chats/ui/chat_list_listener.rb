module Chats
  module Ui
    class ChatListListener < AsyncEventHandler
      include Import.active_job[chat_list_view_repository: 'chats.chat_list_view_repository']

      def call(event)
        send "broadcast_#{event.class.name.demodulize}", event
      end

      private

      def broadcast_CreatedEvent(event)
        user_ids = event.chat_participant_user_ids - [event.current_user_id]
        chat_list_view_repository.where(id: event.chat_id, user_id: user_ids).each do |chat|
          broadcast_prepend_stream(chat, true)
        end
      end

      def broadcast_MessageSentEvent(event)
        user_ids = event.chat_participant_user_ids - [event.current_user_id]
        chat_list_view_repository.where(id: event.chat_id, user_id: user_ids).each do |chat|
          broadcast_replace_stream(chat, true)
        end
      end

      def broadcast_MessageRemovedEvent(event)
        user_ids = event.chat_participant_user_ids - [event.current_user_id]
        chat_list_view_repository.where(id: event.chat_id, user_id: user_ids).each do |chat|
          broadcast_replace_stream(chat, false)
        end
      end

      def broadcast_DeletedEvent(event)
        user_ids = event.chat_participant_user_ids - [event.current_user_id]
        user_ids.each do |user_id|
          broadcast_remove_stream(event.chat_id, user_id)
        end
      end

      def broadcast_ChatParticipantAddedEvent(event)
        chat = chat_list_view_repository.find_by(id: event.chat_id, user_id: event.chat_participant_user_id)
        broadcast_prepend_stream(chat, false)

        Turbo::StreamsChannel.broadcast_replace_to(
          event.chat_participant_user_id,
          target: 'flash',
          partial: 'shared/flash',
          locals: { flash: { success: ['You have been added to a chat!']} }
        )
      end

      def broadcast_ChatParticipantRemovedEvent(event)
        return if event.removed_user_id == event.current_user_id
        broadcast_remove_stream(event.chat_id, event.removed_user_id)
      end

      def broadcast_prepend_stream(chat, move_to_top)
        Turbo::StreamsChannel.broadcast_prepend_to(
          ['chats_list', chat.user_id],
          target: 'chats',
          partial: 'chats/ui/chats/chat_list_item',
          locals: { chat: ::DryObjectMapper::Mapper.call(chat, ::Chats::App::GetChatsListDto), move_to_top: move_to_top }
        )
      end

      def broadcast_replace_stream(chat, move_to_top)
        Turbo::StreamsChannel.broadcast_replace_to(
          ['chats_list', chat.user_id],
          target: chat.id,
          partial: 'chats/ui/chats/chat_list_item',
          locals: { chat: ::DryObjectMapper::Mapper.call(chat, ::Chats::App::GetChatsListDto), move_to_top: move_to_top }
        )
      end

      def broadcast_remove_stream(chat_id, user_id)
        Turbo::StreamsChannel.broadcast_remove_to(['chats_list', user_id], target: chat_id)
      end
    end
  end
end
