module Chats
  module Ui
    class ListQuery < ApplicationStruct
      attribute :current_user_id, Types::String
      attribute? :q, Types::Any.default({}.freeze)
      attribute? :page, Types::Coercible::Integer.default(1.freeze)
      attribute? :page_size, Types::Coercible::Integer.default(Pagy::DEFAULT[:items].freeze)
    end
  end
end
