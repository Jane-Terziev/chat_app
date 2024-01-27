module Chats
  module Ui
    class ChatParticipantListListener < AsyncEventHandler
      def call(event)
        event.chat_participant_user_ids.each do |user_id|
          next if user_id == event.current_user_id

          Turbo::StreamsChannel.broadcast_remove_to(
            [event.chat_id, user_id],
            target: "#{event.removed_user_id}ParticipantList"
          )
        end
      end
    end
  end
end
