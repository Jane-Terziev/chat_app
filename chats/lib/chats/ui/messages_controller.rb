module Chats
  module Ui
    class MessagesController < ApplicationController
      include Import.inject[chat_service: 'chats.chat_service']

      def index
        chat = chat_service.get_chat(params[:chat_id])

        render turbo_stream: [
          turbo_stream.replace('chat_messages', partial: 'index', locals: { chat: chat }),
          turbo_stream.remove("#{params[:chat_id]}UnreadMessageCounter")
        ]
      end

      def create
        chat = chat_service.send_message(
          validator.validate(message_params, SendMessageValidator.new, { chat_id: params[:chat_id] })
        )

        chat_list_dto = ::DryObjectMapper::Mapper.call(chat, ::Chats::App::GetChatsListDto, { unread_messages: 0 })
        chat_details_dto = ::DryObjectMapper::Mapper.call(chat, ::Chats::App::GetChatDetailsDto)

        render turbo_stream: [
          turbo_stream.replace('chat_messages', partial: 'chats/ui/messages/index', locals: { chat: chat_details_dto }),
          turbo_stream.replace(
            params[:chat_id],
            partial: 'chats/ui/chats/chat_list_item',
            locals: { chat: chat_list_dto, move_to_top: true }
          )
        ], status: 201
      rescue ConstraintError => e
        render partial: 'form', locals: { form: e.validator, chat_id: params[:chat_id] }, status: 422
      end

      def destroy
        chat_dto = chat_service.remove_message(params[:chat_id], params[:id])
        flash.now[:notice] = 'Message was successfully removed!'

        render turbo_stream: [
          turbo_stream.replace('flash', partial: 'shared/flash'),
          turbo_stream.remove(params[:id]),
          turbo_stream.replace(
            params[:chat_id], partial: 'chats/ui/chats/chat_list_item', locals: { chat: chat_dto, move_to_top: false }
          )
        ]
      end

      private

      def message_params
        params.require(:message).to_unsafe_h
      end
    end
  end
end