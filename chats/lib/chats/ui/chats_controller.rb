module Chats
  module Ui
    class ChatsController < ApplicationController
      include Import.inject[chat_service: "chats.chat_service"]

      def index
        @chats = chat_service.get_all_chats(
          ListQuery.new(
            current_user_id: current_user.id,
            page: params[:page] || 1,
            page_size: params[:page_size] || 10,
            q: params[:q] || {}
          )
        )
      end

      def create
        chat = chat_service.create_chat(validator.validate(chat_params, CreateChatValidator.new))

        flash.now[:success] = 'Chat was successfully created!'
        render turbo_stream: [
          turbo_stream.replace('flash', partial: "shared/flash"),
          turbo_stream.prepend('chats', partial: 'chat_list_item', locals: { chat: chat, move_to_top: false }),
          turbo_stream.replace('new_chat', partial: 'form', locals: { form: CreateChatValidator.new }),
          turbo_stream.replace('newChatDialog', partial: 'new_dialog')
        ], status: 201
      rescue ConstraintError => e
        render partial: 'form', locals: { form: e.validator }, status: 422
      end

      def destroy
        chat_service.delete_chat(params[:id])
        render turbo_stream: [
          turbo_stream.replace(
            'flash',
            partial: 'shared/flash',
            locals: { flash: { success: ["Chat was successfully deleted!"] } }
          ),
          turbo_stream.replace('chatMessageContainer'),
          turbo_stream.remove(params[:id])
        ]
      end

      def acknowledge
        chat_service.acknowledge_messages(params[:chat_id])
        render turbo_stream: turbo_stream.remove("#{params[:chat_id]}UnreadMessageCounter")
      end

      def leave_chat
        chat_service.remove_chat_participant(params[:chat_id], current_user.id)
        flash.now[:notice] = 'Successfully left the chat!'
        render turbo_stream: [
          turbo_stream.replace('flash', partial: 'shared/flash'),
          turbo_stream.remove(params[:chat_id]),
          turbo_stream.remove('chatMessageContainer')
        ]
      end

      private

      def chat_params
        params.require(:chat).to_unsafe_h
      end
    end
  end
end
