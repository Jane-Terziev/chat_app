module Chats
  module Domain
    class Message < ApplicationRecord
      self.table_name = "messages"

      has_many_attached :attachments, dependent: :destroy
      belongs_to :chat_participant
      has_many :unacknowledged_messages, dependent: :delete_all

      def attachment_files
        ActiveStorage::Current.url_options = { host: 'localhost:3000' }
        attachments.map do |attachment|
          FileDto.new(
            url: attachment.url,
            content_type: attachment.blob.content_type,
            filename: attachment.blob.filename.to_s
          )
        end
      end
    end
  end
end
