module Chats
  module App
    module ReadModel
      class ChatParticipantSelectDto < ApplicationReadStruct
        attribute :id, Types::String
        attribute :first_name, Types::String
        attribute :last_name, Types::String

        def full_name
          "#{self.first_name} #{self.last_name}"
        end
      end
    end
  end
end
