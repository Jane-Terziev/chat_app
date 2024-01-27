module Chats
  module Ui
    class AddChatParticipantValidator < ApplicationContract
      params do
        required(:user_ids).value(:array?, min_size?: 1).each(:string)
      end

      def self.command
        ::DryStructGenerator::StructGenerator.new.call(
          self,
          {
            chat_id: { required: true, type: 'string', null: false }
          }
        )
      end
    end
  end
end