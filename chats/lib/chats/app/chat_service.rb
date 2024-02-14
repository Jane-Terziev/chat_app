module Chats
  module App
    class ChatService < ApplicationService
      include Import[
                chat_repository: "chats.chat_repository",
                message_repository: "chats.message_repository",
                current_user_repository: 'current_user_repository',
                unacknowledged_message_repository: 'chats.unacknowledged_message_repository'
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

        chat.id
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
          new_messages = []
          new_messages << chat.send_message(
            user_id: current_user_repository.authenticated_identity.id,
            message: command.message
          ) if command.message.present?

          new_messages += command.attachments.map do |attachment|
            chat.send_attachment(
              user_id: current_user_repository.authenticated_identity.id,
              attachment: attachment
            )
          end

          [chat_repository.save!(chat), new_messages]
        end

        publish_all(chat)

        new_messages.map(&:id)
      end

      def acknowledge_messages(chat_id)
        ActiveRecord::Base.transaction do
          raise ActiveRecord::RecordNotFound unless chat_repository.exists?(id: chat_id)
          unacknowledged_message_repository.where(
            chat_id: chat_id,
            user_id: current_user_repository.authenticated_identity.id
          ).delete_all
        end
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
      end

      def add_chat_participants(command)
        chat = ActiveRecord::Base.transaction do
          chat = chat_repository.find(command.chat_id)
          chat.add_chat_participants(user_ids: command.user_ids)

          chat_repository.save!(chat)
        end

        publish_all(chat)
      end

      def remove_chat_participant(chat_id, user_id)
        chat = ActiveRecord::Base.transaction do
          chat = chat_repository.find(chat_id)
          chat.remove_chat_participant(user_id: user_id)

          chat_repository.save!(chat)
        end

        publish_all(chat)
      end
    end
  end
end
