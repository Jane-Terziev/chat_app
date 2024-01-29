class CreateChatListViews < ActiveRecord::Migration[7.1]
  def change
    create_view :chat_list_views
  end
end
