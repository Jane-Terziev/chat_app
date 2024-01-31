module Chats
  module Domain
    class User < ApplicationRecord
      self.table_name = "users"
    end
  end
end
