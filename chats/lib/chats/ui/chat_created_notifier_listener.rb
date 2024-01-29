module Chats
  module Ui
    class ChatCreatedNotifierListener < AsyncEventHandler
      def call(event)
        user_ids = event.chat_participant_user_ids - [event.current_user_id]
        user_ids.each do |user_id|
          Turbo::StreamsChannel.broadcast_replace_to(
            user_id,
            target: 'flash',
            partial: 'shared/flash',
            locals: { flash: { notice: ['You have been added to a new chat!'] } }
          )
        end
      end
    end
  end
end
