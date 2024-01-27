module Chats
  module Domain
    class Chat < AggregateRoot
      self.table_name = "chats"

      has_many :chat_participants, autosave: true, dependent: :destroy
      has_many :unacknowledged_messages, autosave: true

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
          chat_participants: user_ids.map { |it| ChatParticipant.new(id: SecureRandom.uuid, user_id: it) },
          user_id: user_id
        )

        chat.apply_event(CreatedEvent.new(data: { chat_id: id, participant_user_ids: user_ids }))
        chat
      end

      def delete_chat
        apply_event(
          DeletedEvent.new(
            data: {
              chat_id: self.id,
              participant_user_ids: chat_participants.map(&:user_id)
            }
          )
        )

        self
      end

      def send_message(user_id:, message:, attachments: [])
        chat_participant = chat_participants.find { |it| it.user_id == user_id }

        if message.present?
          chat_message = Message.new(
            id: SecureRandom.uuid,
            message: message,
            unacknowledged_messages: chat_participants.filter { |it| it.user_id != user_id }.map do |participant|
              UnacknowledgedMessage.new(user_id: participant.user_id, chat_id: self.id)
            end
          )

          chat_participant.messages << chat_message

          apply_event(
            MessageSentEvent.new(
              data: {
                chat_id: self.id,
                message_id: chat_message.id
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
              attachments: [attachment]
            )
            chat_participant.messages << chat_message
            apply_event(
              MessageSentEvent.new(
                data: {
                  chat_id: self.id,
                  message_id: chat_message.id
                }
              )
            )
          end
        end

        self
      end

      def remove_message(message_id:, user_id:)
        message = chat_participants.find do |it|
          it.user_id == user_id
        end.messages.find { |it| it.id == message_id }

        raise ActiveRecord::RecordNotFound unless message.present?

        message.mark_for_destruction

        apply_event(
          MessageRemovedEvent.new(
            data: {
              chat_id: self.id,
              message_id: message_id,
              participant_user_ids: chat_participants.map(&:user_id)
            }
          )
        )
        self
      end

      def acknowledge_messages(user_id:)
        unacknowledged_messages.filter { |it| it.user_id == user_id }.each do |unacknowledged_message|
          unacknowledged_message.mark_for_destruction
        end

        self
      end

      def add_chat_participants(user_ids:)
        user_ids.each do |user_id|
          chat_participants << ChatParticipant.new(id: SecureRandom.uuid, user_id: user_id)
          apply_event(ChatParticipantAddedEvent.new(data: { chat_id: self.id, chat_participant_user_id: user_id }))
        end

        self
      end

      def remove_chat_participant(user_id:)
        chat_participants.find {|it| it.user_id == user_id }&.mark_for_destruction
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

      def messages
        chat_participants.map(&:messages).flatten.sort_by { |it| it.created_at }
      end

      def last_message
        chat_message = messages.last
        return "" unless chat_message.present?
        return chat_message.message if chat_message.message.present?
        "Attachment Sent."
      end

      def last_message_timestamp
        messages.last&.created_at
      end

      def unread_messages(user_id)
        unacknowledged_messages.filter { |it| it.user_id == user_id }.size
      end
    end
  end
end
