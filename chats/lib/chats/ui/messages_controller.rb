module Chats
  module Ui
    class MessagesController < ApplicationController
      include Import.inject[chat_service: 'chats.chat_service']

      def index
        paginated_result = chat_service.get_chat(
          MessageListQuery.new(
            chat_id: params[:chat_id],
            page: params[:page] || 1,
            page_size: params[:page_size] || 10,
            q: params[:q] || {}
          )
        )

        render turbo_stream: [
          turbo_stream.replace('chat_messages', partial: 'index', locals: { paginated_result: paginated_result }),
          turbo_stream.remove("#{params[:chat_id]}UnreadMessageCounter")
        ]
      end

      def load_more
        @paginated_result = chat_service.get_chat(
          MessageListQuery.new(
            chat_id: params[:chat_id],
            page: params[:page] || 1,
            page_size: params[:page_size] || 10,
            q: params[:q] || {}
          )
        )
      end

      def create
        chat_dto, new_messages_dto = chat_service.send_message(
          validator.validate(message_params, SendMessageValidator.new, { chat_id: params[:chat_id] })
        )

        append_message_streams = new_messages_dto.map do |new_message_dto|
          turbo_stream.append(
            'messageContainer',
            partial: 'message_list_item',
            locals: { message: new_message_dto, user_id: current_user.id, should_scroll: true, acknowledge: false }
          )
        end

        render turbo_stream: [
          turbo_stream.replace(
            params[:chat_id],
            partial: 'chats/ui/chats/chat_list_item',
            locals: { chat: chat_dto, move_to_top: true }
          ),
          turbo_stream.replace('message_form', partial: 'form', locals: { form: SendMessageValidator.new, chat_id: params[:chat_id] }),
          *append_message_streams
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