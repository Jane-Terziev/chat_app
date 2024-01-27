class CreateUnacknowledgedMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :unacknowledged_messages do |t|
      t.string :message_id
      t.string :user_id
      t.string :chat_id

      t.timestamps
    end

    add_foreign_key :unacknowledged_messages, :messages
    add_foreign_key :unacknowledged_messages, :users
    add_foreign_key :unacknowledged_messages, :chats

    add_index :unacknowledged_messages, :message_id
    add_index :unacknowledged_messages, :user_id
    add_index :unacknowledged_messages, :chat_id
  end
end
