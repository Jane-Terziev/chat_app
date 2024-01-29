module Chats
  module App
    module ReadModel
      class PaginatedChatDetailsDto < ApplicationReadStruct
        attribute :pagination, Types::Any
        attribute :data, GetChatDetailsDto
      end
    end
  end
end
