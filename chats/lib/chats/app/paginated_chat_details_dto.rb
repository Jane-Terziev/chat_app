module Chats
  module App
    class PaginatedChatDetailsDto < ApplicationReadStruct
      attribute :pagination, Types::Any
      attribute :data, GetChatDetailsDto
    end
  end
end
