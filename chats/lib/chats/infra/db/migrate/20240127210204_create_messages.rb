class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages, id: false do |t|
      t.string :id, primary_key: true, limit: 36
      t.string :message
      t.string :chat_participant_id

      t.timestamps
    end

    add_foreign_key :messages, :chat_participants
    add_index :messages, :chat_participant_id
  end
end
