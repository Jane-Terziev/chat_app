module Chats
  module Ui
    class ParticipantsController < ApplicationController
      include Import.inject[chat_service: 'chats.chat_service']

      def create
        chat_participant_dto = chat_service.add_chat_participants(
          validator.validate(params[:chat]&.to_unsafe_h, AddChatParticipantValidator.new, { chat_id: params[:chat_id] })
        )

        flash.now[:notice] = 'Users were successfully added to the chat!'
        render turbo_stream: [
          turbo_stream.replace('flash', partial: 'shared/flash'),
          turbo_stream.replace('chatParticipantList', partial: 'chat_participant_list', locals: { chat: chat_participant_dto }),
          turbo_stream.replace(
            'add_chat_participant_form',
            partial: 'add_chat_participant_form',
            locals: { form: AddChatParticipantValidator.new, chat_id: params[:chat_id] }
          ),
          turbo_stream.replace('addChatParticipantDialog', partial: 'chat_add_chat_participants_dialog', locals: { chat: chat_participant_dto })
        ]
      rescue ConstraintError => e
        render partial: 'add_chat_participant_form', locals: { form: e.validator, chat_id: params[:chat_id] }, status: 422
      end

      def destroy
        chat_service.remove_chat_participant(params[:chat_id], params[:id])
        flash.now[:notice] = 'User was successfully removed!'
        render turbo_stream: [
          turbo_stream.replace('flash', partial: 'shared/flash'),
          turbo_stream.remove("#{params[:id]}ParticipantList")
        ]
      end
    end
  end
end