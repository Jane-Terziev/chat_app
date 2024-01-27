module Chats
  module Ui
    class CreateChatValidator < ApplicationContract
      params do
        required(:name).value(Types::StrippedString, :filled?)
        required(:user_ids).value(:array?).each(:string)
      end
    end
  end
end
