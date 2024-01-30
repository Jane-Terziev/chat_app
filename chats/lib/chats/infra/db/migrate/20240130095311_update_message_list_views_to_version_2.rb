class UpdateMessageListViewsToVersion2 < ActiveRecord::Migration[7.1]
  def change
  
    update_view :message_list_views, version: 2, revert_to_version: 1
  end
end
