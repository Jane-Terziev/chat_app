module Chats
  module Domain
    class Chat < AggregateRoot
      self.table_name = "chats"

      has_many :chat_participants, autosave: true, dependent: :destroy
      has_many :unacknowledged_messages, autosave: true, dependent: :delete_all

      def self.ransackable_attributes(auth_object = nil)
        %w[name]
      end

      def self.ransackable_associations(auth_object = nil)
        ["chat_participants"]
      end

      def self.create_new(id: SecureRandom.uuid, name:, user_ids:, user_id:)
        chat = new(
          id: id,
          name: name,
          chat_participants: user_ids.map { |it| ChatParticipant.create_new(user_id: it, status: 'active') },
          user_id: user_id
        )

        chat.apply_event(CreatedEvent.new(data: { chat_id: id, chat_participant_user_ids: user_ids }))
        chat
      end

      def delete_chat
        apply_event(
          DeletedEvent.new(
            data: {
              chat_id: self.id,
              chat_participant_user_ids: chat_participants.map(&:user_id)
            }
          )
        )

        self
      end

      def send_message(user_id:, message:, attachments: [])
        chat_participant = chat_participants.find { |it| it.user_id == user_id }
        new_messages = []

        if message.present?
          chat_message = Message.new(
            id: SecureRandom.uuid,
            message: message,
            unacknowledged_messages: chat_participants.filter { |it| it.user_id != user_id }.map do |participant|
              UnacknowledgedMessage.new(user_id: participant.user_id, chat_id: self.id)
            end,
            chat_id: self.id,
            message_type: Message::MESSAGE_TYPES['message']
          )

          chat_participant.messages << chat_message

          new_messages << chat_message

          apply_event(
            MessageSentEvent.new(
              data: {
                chat_id: self.id,
                message_id: chat_message.id,
                chat_participant_user_ids: chat_participants.map(&:user_id)
              }
            )
          )
        end

        if attachments.present?
          attachments.each do |attachment|
            chat_message = Message.new(
              id: SecureRandom.uuid,
              unacknowledged_messages: chat_participants.filter { |it| it.user_id != user_id }.map do |participant|
                UnacknowledgedMessage.new(user_id: participant.user_id, chat_id: self.id)
              end,
              attachment: attachment,
              chat_id: self.id,
            )

            attachment.content_type == 'application/pdf' ? chat_message.message_type = Message::MESSAGE_TYPES['file'] :
              chat_message.message_type = Message::MESSAGE_TYPES['image']

            chat_participant.messages << chat_message

            new_messages << chat_message

            apply_event(
              MessageSentEvent.new(
                data: {
                  chat_id: self.id,
                  message_id: chat_message.id,
                  chat_participant_user_ids: chat_participants.map(&:user_id)
                }
              )
            )
          end
        end

        new_messages
      end

      def apply_message_removed_event(message_id:)
        apply_event(
          MessageRemovedEvent.new(
            data: {
              chat_id: self.id,
              message_id: message_id,
              chat_participant_user_ids: chat_participants.map(&:user_id)
            }
          )
        )
        self
      end

      def add_chat_participants(user_ids:)
        user_ids.each do |user_id|
          existing_participant = chat_participants.find { |it| it.user_id == user_id }

          if existing_participant.present?
            existing_participant.status = ChatParticipant::STATUS['active'] if existing_participant.is_removed?
          else
            chat_participants << ChatParticipant.create_new(user_id: user_id)
          end

          apply_event(ChatParticipantAddedEvent.new(data: { chat_id: self.id, chat_participant_user_id: user_id }))
        end

        self
      end

      def remove_chat_participant(user_id:)
        chat_participant = chat_participants.find { |it| it.user_id == user_id }

        raise ActiveRecord::RecordNotFound.new unless chat_participant.present?

        chat_participant.status = ChatParticipant::STATUS['removed']

        apply_event(
          ChatParticipantRemovedEvent.new(
            data: {
              chat_id: self.id,
              removed_user_id: user_id,
              chat_participant_user_ids: chat_participants.map(&:user_id)
            }
          )
        )
        self
      end
    end
  end
end
