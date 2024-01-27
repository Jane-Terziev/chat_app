module Chats
  module Domain
    class FileDto < ApplicationReadStruct
      attribute :url, Types::String
      attribute :content_type, Types::String
      attribute :filename, Types::String
    end
  end
end
