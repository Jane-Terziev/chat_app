class CreateChatParticipantViews < ActiveRecord::Migration[7.1]
  def change
    create_view :chat_participant_views
  end
end
