module Chats
  module Ui
    class ChatCreatedNotifierListener < AsyncEventHandler
      def call(event)
        event.participant_user_ids.each do |user_id|
          next if user_id == event.current_user_id

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
