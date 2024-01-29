module Chats
  module App
    class ChatService < ApplicationService
      include Import[
                chat_repository: "chats.chat_repository",
                message_repository: "chats.message_repository",
                current_user_repository: 'current_user_repository',
                chat_list_view_repository: 'chats.chat_list_view_repository',
                message_list_view_repository: 'chats.message_list_view_repository'
              ]

      def create_chat(command)
        chat = ActiveRecord::Base.transaction do
          chat_repository.save!(
            chat_repository.create_new(
              name: command.name,
              user_ids: command.user_ids + [current_user_repository.authenticated_identity.id],
              user_id: current_user_repository.authenticated_identity.id
            )
          )
        end

        publish_all(chat)

        map_into(
          chat_list_view_repository.find_by!(id: chat.id, user_id: current_user_repository.authenticated_identity.id),
          GetChatsListDto
        )
      end

      def delete_chat(id)
        chat = ActiveRecord::Base.transaction do
          chat = chat_repository.find(id).delete_chat
          chat_repository.delete!(chat)
        end

        publish_all(chat)
      end

      def send_message(command)
        chat, new_messages = ActiveRecord::Base.transaction do
          chat = chat_repository.find(command.chat_id)
          new_messages = chat.send_message(
            user_id: current_user_repository.authenticated_identity.id,
            message: command.message,
            attachments: command.attachments
          )
          [chat_repository.save!(chat), new_messages]
        end

        publish_all(chat)
        [
          map_into(
            chat_list_view_repository.find_by!(id: chat.id, user_id: current_user_repository.authenticated_identity.id),
            GetChatsListDto
          ),
          map_into(
            new_messages,
            MessageDto,
            { user_id: current_user_repository.authenticated_identity.id, chat_id: command.chat_id }
          )
        ]
      end

      def acknowledge_messages(chat_id)
        chat = ActiveRecord::Base.transaction do
          chat = chat_repository.includes(:unacknowledged_messages)
                                .where(unacknowledged_messages: { user_id: current_user_repository.authenticated_identity.id })
                                .find(chat_id)

          chat.acknowledge_messages(user_id: current_user_repository.authenticated_identity.id)
          chat_repository.save!(chat)
        end

        publish_all(chat)
      end

      def remove_message(chat_id, message_id)
        chat = ActiveRecord::Base.transaction do
          chat = chat_repository.find(chat_id)

          message_repository.joins(:chat_participant).where(
            chat_participant: { user_id: current_user_repository.authenticated_identity.id, chat_id: chat_id }
          ).find(message_id).destroy!

          chat.apply_message_removed_event(message_id: message_id)
          chat_repository.save!(chat)
        end

        publish_all(chat)

        map_into(
          chat_list_view_repository.find_by!(id: chat_id, user_id: current_user_repository.authenticated_identity.id),
          GetChatsListDto
        )
      end

      def add_chat_participants(command)
        chat = ActiveRecord::Base.transaction do
          chat = chat_repository.includes(chat_participants: :user).find(command.chat_id)
          chat.add_chat_participants(user_ids: command.user_ids)

          chat_repository.save!(chat)
        end

        publish_all(chat)

        map_into(chat.chat_participants, ChatParticipantDto)
      end

      def remove_chat_participant(chat_id, user_id)
        chat = ActiveRecord::Base.transaction do
          chat = chat_repository.includes(:chat_participants).find(chat_id)
          chat.remove_chat_participant(user_id: user_id)

          chat_repository.save!(chat)
        end

        publish_all(chat)

        map_into(chat.chat_participants, ChatParticipantDto)
      end


      def get_all_chats(query)
        chats = chat_list_view_repository.where(user_id: current_user_repository.authenticated_identity.id)
                       .order('updated_at DESC')
                       .ransack(query.q)
                       .result

        result = pagy_countless(chats, items: query.page_size, page: query.page)

        pagy_metadata = result[0]
        paginated_data = result[1]


        PaginationDto.new(
          data: map_into(paginated_data, GetChatsListDto),
          pagination: pagy_metadata
        )
      end

      def get_chat(query)
        chat = ActiveRecord::Base.transaction do
          chat = chat_repository.find(query.chat_id)
          chat.unacknowledged_messages.where(user_id: current_user_repository.authenticated_identity.id).delete_all
          chat_repository.save!(chat)
        end

        publish_all(chat)

        pagy_metadata, paginated_data = pagy_countless(
          message_list_view_repository.where(chat_id: query.chat_id).order('created_at DESC'),
          items: query.page_size,
          page: query.page
        )

        attachment_file_dtos = ::ActiveStorage::Attachment.includes(:blob).where(
          record_type: 'Chats::Domain::Message',
          record_id: paginated_data.map(&:id)
        ).map  do |attachment_file|
          ::Chats::Domain::FileDto.new(
            message_id: attachment_file.record_id,
            url: attachment_file.url,
            content_type: attachment_file.content_type,
            filename: attachment_file.filename.to_s
          )
        end

        message_dtos = paginated_data.map do |message|
          attachment_file = attachment_file_dtos.find { |it| it.message_id == message.id }
          map_into(message, MessageDto, { attachment_file: attachment_file })
        end

        chat_dto = map_into(chat, GetChatDetailsDto, { messages: message_dtos.reverse })

        PaginatedChatDetailsDto.new(
          data: chat_dto,
          pagination: pagy_metadata
        )
      end

      def get_chat_participants(chat_id)
        map_into(chat_repository.includes(chat_participants: :user).find(chat_id).chat_participants, ChatParticipantDto)
      end
    end
  end
end
