module Chats
  module Domain
    module ReadModel
      class MessageListView < ApplicationRecord
        self.table_name = 'message_list_views'
        self.primary_key = :id

        def attachment
          ::ActiveStorage::Attachment.find_by(record_type: 'Chats::Domain::Message', record_id: self.id)
        end

        def attachment_file
          return nil unless attachment.present?
          ActiveStorage::Current.url_options = { host: 'localhost:3000' }
          FileDto.new(
            message_id: self.id,
            url: attachment.url,
            content_type: attachment.content_type,
            filename: attachment.filename.to_s
          )
        end
      end
    end
  end
end
