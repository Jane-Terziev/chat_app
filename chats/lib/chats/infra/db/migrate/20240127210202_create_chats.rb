class CreateChats < ActiveRecord::Migration[7.1]
  def change
    create_table :chats, id: false do |t|
      t.string :id, limit: 36, primary_key: true
      t.string :name
      t.string :user_id

      t.timestamps
    end

    add_foreign_key :chats, :users
    add_index :chats, :user_id
  end
end
