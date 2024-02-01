module Chats
  module Domain
    class Message < ApplicationRecord
      self.table_name = "messages"

      has_one_attached :attachment, dependent: :delete

      belongs_to :chat_participant

      has_many :chat_message_links, dependent: :delete_all
      has_many :unacknowledged_messages, dependent: :delete_all

      def attachment_file
        return nil unless attachment.attached?
        if ENV.fetch('IMAGE_STORAGE', 'local') == 'local'
          ActiveStorage::Current.url_options = { host: 'localhost:3000' }
        end
        FileDto.new(
          message_id: self.id,
          url: attachment.url,
          content_type: attachment.blob.content_type,
          filename: attachment.blob.filename.to_s
        )
      end
    end
  end
end
