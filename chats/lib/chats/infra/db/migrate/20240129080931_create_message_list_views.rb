class CreateMessageListViews < ActiveRecord::Migration[7.1]
  def change
    create_view :message_list_views
  end
end
