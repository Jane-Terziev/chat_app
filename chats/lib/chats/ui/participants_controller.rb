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
          turbo_stream.replace(
            'chatParticipantList',
            partial: 'participant_list',
            locals: { chat: chat_participant_dto }
          ),
          turbo_stream.replace(
            'addChatParticipantDialog',
            partial: 'participants_dialog',
            locals: { chat: chat_participant_dto }
          )
        ], status: 201
      rescue ConstraintError => e
        chat_participant_dto = DryObjectMapper::Mapper.call(
          ::Chats::Domain::Chat.find(params[:chat_id]),
          ::Chats::App::GetChatParticipantDto
        )

        render partial: 'form', locals: {
          form: e.validator,
          chat_id: params[:chat_id],
          participants: chat_participant_dto.chat_participants
        }, status: 422
      end

      def destroy
        chat_participant_dto = chat_service.remove_chat_participant(params[:chat_id], params[:id])
        flash.now[:notice] = 'User was successfully removed!'
        render turbo_stream: [
          turbo_stream.replace('flash', partial: 'shared/flash'),
          turbo_stream.remove("#{params[:id]}ParticipantList"),
          turbo_stream.replace(
            'addChatParticipantDialog',
            partial: 'participants_dialog',
            locals: { chat: chat_participant_dto }
          )
        ]
      end
    end
  end
end