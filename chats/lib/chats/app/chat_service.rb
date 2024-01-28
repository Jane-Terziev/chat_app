module Chats
  module App
    class ChatService < ApplicationService
      include Import[
                chat_repository: "chats.chat_repository",
                current_user_repository: 'current_user_repository'
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

        map_into(chat, GetChatsListDto, { unread_messages: 0 })
      end

      def delete_chat(id)
        chat = ActiveRecord::Base.transaction do
          chat = chat_repository.find(id).delete_chat
          chat_repository.delete!(chat)
        end

        publish_all(chat)
      end

      def send_message(command)
        chat = ActiveRecord::Base.transaction do
          chat = chat_repository.includes(
            chat_participants: [:user, messages: [:attachments_attachments, :attachments_blobs] ]
          ).find(command.chat_id)
          chat.send_message(
            user_id: current_user_repository.authenticated_identity.id,
            message: command.message,
            attachments: command.attachments
          )
          chat_repository.save!(chat)
        end

        publish_all(chat)

        chat
      end

      def acknowledge_messages(chat_id)
        chat = ActiveRecord::Base.transaction do
          chat = chat_repository.includes(:unacknowledged_messages).find(chat_id)
          chat.acknowledge_messages(user_id: current_user_repository.authenticated_identity.id)
          chat_repository.save!(chat)
        end

        publish_all(chat)
      end

      def remove_message(chat_id, message_id)
        chat = ActiveRecord::Base.transaction do
          chat = chat_repository.includes(chat_participants: :messages).find(chat_id)
          chat.remove_message(message_id: message_id, user_id: current_user_repository.authenticated_identity.id)
          chat_repository.save!(chat)
        end

        publish_all(chat)

        map_into(chat, GetChatsListDto, { unread_messages: 0 })
      end

      def add_chat_participants(command)
        chat = ActiveRecord::Base.transaction do
          chat = chat_repository.find(command.chat_id)
          chat.add_chat_participants(user_ids: command.user_ids)

          chat_repository.save!(chat)
        end

        publish_all(chat)

        map_into(chat, GetChatParticipantDto)
      end

      def remove_chat_participant(chat_id, user_id)
        chat = ActiveRecord::Base.transaction do
          chat = chat_repository.find(chat_id)
          chat.remove_chat_participant(user_id: user_id)
          chat_repository.save!(chat)
        end

        publish_all(chat)

        map_into(chat, GetChatParticipantDto)
      end


      def get_all_chats(query)
        chats = chat_repository.joins(:chat_participants)
                       .where(chat_participants: { user_id: current_user_repository.authenticated_identity.id })
                       .includes(:unacknowledged_messages)
                       .order('updated_at DESC')
                       .ransack(query.q)
                       .result

        chats.map do |chat|
          map_into(
            chat,
            GetChatsListDto,
            {
              unread_messages: chat.unread_messages(current_user_repository.authenticated_identity.id)
            }
          )
        end
      end

      def get_chat(id)
        chat = ActiveRecord::Base.transaction do
          chat = chat_repository.includes(
            :unacknowledged_messages,
            chat_participants: [:user, messages: [:attachments_attachments, :attachments_blobs] ],
          ).find(id)
          chat.acknowledge_messages(user_id: current_user_repository.authenticated_identity.id)
          chat_repository.save!(chat)
        end

        publish_all(chat)

        map_into(chat, GetChatDetailsDto)
      end
    end
  end
end
