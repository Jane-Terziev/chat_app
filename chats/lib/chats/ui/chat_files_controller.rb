module Chats
  module Ui
    class ChatFilesController < ApplicationController
      include Import.inject[chat_read_service: 'chats.chat_read_service']

      def index
        @paginated_result = chat_read_service.get_files_from_chat(
          FilesListQuery.new(
            chat_id: params[:chat_id],
            page: params[:page] || 1,
            page_size: params[:page_size] || 10,
            q: params[:q] || {}
          )
        )
      end
    end
  end
end
