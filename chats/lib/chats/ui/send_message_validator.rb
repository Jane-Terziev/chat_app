module Chats
  module Ui
    class SendMessageValidator < ApplicationContract
      params do
        optional(:message).value(Types::StrippedString)
        optional(:attachments).value(:array?)
      end

      rule(:message) do
        unless value.present? || values[:attachments].present?
          key(:message).failure('or attachment must be sent!')
        end
      end

      def self.command
        ::DryStructGenerator::StructGenerator.new.call(
          self,
          {
            chat_id: { required: true, type: 'string', null: false },
            attachments: { required: true, type: 'array', default: [] }
          }
        )
      end
    end
  end
end
