class CreateChatMessageLinks < ActiveRecord::Migration[7.1]
  def change
    create_table :chat_message_links, id: false do |t|
      t.string :id, primary_key: true, limit: 36
      t.string :message_id
      t.string :link, null: false

      t.timestamps
    end

    add_foreign_key :chat_message_links, :messages
    add_index :chat_message_links, :message_id
  end
end
