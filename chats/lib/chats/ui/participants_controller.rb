module Chats
  module Ui
    class ParticipantsController < ApplicationController
      include Import.inject[chat_service: 'chats.chat_service', chat_read_service: 'chats.chat_read_service']

      def index
        participants = chat_read_service.get_active_chat_participants(params[:chat_id])
        render :index, locals: { participants: participants }
      end

      def new
        participants = chat_read_service.get_participants_select_options_for_chat(params[:chat_id])
        render :new, locals: { form: AddChatParticipantValidator.new, participants: participants }
      end

      def create
        chat_service.add_chat_participants(
          validator.validate(params[:chat]&.to_unsafe_h, AddChatParticipantValidator.new, { chat_id: params[:chat_id] })
        )

        chat_participants_dto = chat_read_service.get_active_chat_participants(params[:chat_id])

        flash.now[:notice] = 'Users were successfully added to the chat!'
        render turbo_stream: [
          turbo_stream.replace('flash', partial: 'shared/flash'),
          turbo_stream.replace(
            'chatParticipantList',
            partial: 'participant_list',
            locals: { participants: chat_participants_dto, chat_id: params[:chat_id], user_id: current_user.id }
          ),
          turbo_stream.replace(
            'addChatParticipantDialog',
            partial: 'participants_dialog',
            locals: { chat_id: params[:chat_id], participants: chat_participants_dto }
          )
        ], status: 201
      rescue ConstraintError => e
        participants = chat_read_service.get_participants_select_options_for_chat(params[:chat_id])
        render :new, locals: { form: e.validator, chat_id: params[:chat_id], participants: participants }, status: 422
      end

      def destroy
        chat_service.remove_chat_participant(params[:chat_id], params[:id])
        chat_participants_dto = chat_read_service.get_active_chat_participants(params[:chat_id])

        flash.now[:notice] = 'User was successfully removed!'
        render turbo_stream: [
          turbo_stream.replace('flash', partial: 'shared/flash'),
          turbo_stream.remove("#{params[:id]}ParticipantList"),
          turbo_stream.replace(
            'addChatParticipantDialog',
            partial: 'participants_dialog',
            locals: { chat_id: params[:chat_id], participants: chat_participants_dto }
          )
        ]
      end
    end
  end
end