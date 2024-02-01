module Chats
  module App
    module ReadModel
      class ChatService < ApplicationService
        include Import[
                  current_user_repository: 'current_user_repository',
                  chat_list_view_repository: 'chats.chat_list_view_repository',
                  message_list_view_repository: 'chats.message_list_view_repository',
                  chat_participant_view_repository: 'chats.chat_participant_view_repository',
                  user_repository: 'chats.user_repository',
                  chat_message_link_repository: 'chats.chat_message_link_repository',
                ]

        def get_all_chats(query)
          chats = chat_list_view_repository.where(user_id: current_user_repository.authenticated_identity.id)
                                           .order("last_message_timestamp DESC NULLS LAST, updated_at DESC NULLS LAST")
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

        def get_chat_list_dto(chat_id)
          map_into(
            chat_list_view_repository.find_by!(id: chat_id, user_id: current_user_repository.authenticated_identity.id),
            GetChatsListDto
          )
        end

        def get_chat(query)
          pagy_metadata, paginated_data = pagy_countless(
            message_list_view_repository.where(chat_id: query.chat_id).order('created_at DESC'),
            items: query.page_size,
            page: query.page
          )

          # Active Storage does not work well with adding attachment to model with different name
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

          chat_dto = map_into(
            chat_list_view_repository.find_by!(
              id: query.chat_id,
              user_id: current_user_repository.authenticated_identity.id
            ),
            GetChatDetailsDto,
            { messages: message_dtos.reverse }
          )

          PaginatedChatDetailsDto.new(
            data: chat_dto,
            pagination: pagy_metadata
          )
        end

        def get_images_from_chat(query)
          pagy_metadata, paginated_data = pagy_countless(
            ActiveStorage::Attachment.joins(
              "INNER JOIN messages ON CAST(messages.id AS uuid) = active_storage_attachments.record_id AND
               active_storage_attachments.record_type = 'Chats::Domain::Message'
              "
            ).where("messages.chat_id = ?", query.chat_id).joins(:blob).where(
              "active_storage_blobs.content_type LIKE ?", 'image%'
            ).order('messages.created_at DESC'),
            items: query.page_size,
            page: query.page
          )

          images_dto = paginated_data.map do |attachment_file|
            ::Chats::Domain::FileDto.new(
              message_id: attachment_file.record_id,
              url: attachment_file.url,
              content_type: attachment_file.content_type,
              filename: attachment_file.filename.to_s
            )
          end

          PaginationDto.new(
            data: images_dto.reverse,
            pagination: pagy_metadata
          )
        end

        def get_files_from_chat(query)
          pagy_metadata, paginated_data = pagy_countless(
            ActiveStorage::Attachment.joins(
              "INNER JOIN messages ON CAST(messages.id AS uuid) = active_storage_attachments.record_id AND
               active_storage_attachments.record_type = 'Chats::Domain::Message'
              "
            ).where(
              "messages.chat_id = ?", query.chat_id
            ).joins(:blob).where(
              blob: { content_type: 'application/pdf' }
            ).order('messages.created_at DESC'),
            items: query.page_size,
            page: query.page
          )

          files_dto = paginated_data.map do |attachment|
            ::Chats::Domain::FileDto.new(
              message_id: attachment.record_id,
              url: attachment.url,
              content_type: attachment.content_type,
              filename: attachment.filename.to_s
            )
          end

          PaginationDto.new(
            data: files_dto.reverse,
            pagination: pagy_metadata
          )
        end

        def get_links_from_chat(query)
          pagy_metadata, paginated_data = pagy_countless(
            chat_message_link_repository.joins(:message)
                                        .where(message: { chat_id: query.chat_id })
                                        .order('created_at DESC'),
            items: query.page_size,
            page: query.page
          )

          PaginationDto.new(
            data: map_into(paginated_data, ChatMessageLinkDto),
            pagination: pagy_metadata
          )
        end

        def get_active_chat_participants(chat_id)
          map_into(chat_participant_view_repository.where(chat_id: chat_id, status: 'active'), ChatParticipantDto)
        end

        def get_participants_select_options_for_new_chat
          map_into(
            user_repository.where.not(id: current_user_repository.authenticated_identity.id),
            ChatParticipantSelectDto
          )
        end

        def get_participants_select_options_for_chat(chat_id)
          map_into(
            user_repository.all.where.not(
              id: chat_participant_view_repository.where(chat_id: chat_id, status: 'active').map(&:user_id)
            ),
            ChatParticipantSelectDto
          )
        end
      end
    end
  end
end
