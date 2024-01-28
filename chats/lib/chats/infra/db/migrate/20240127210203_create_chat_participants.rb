class CreateChatParticipants < ActiveRecord::Migration[7.1]
  def change
    create_table :chat_participants, id: false do |t|
      t.string :id, primary_key: true, limit: 36

      t.string :user_id
      t.string :chat_id

      t.timestamps
    end

    add_foreign_key :chat_participants, :users
    add_foreign_key :chat_participants, :chats
    add_index :chat_participants, :user_id
    add_index :chat_participants, :chat_id
  end
end
