module Authentication
  module Domain
    class User < AggregateRoot
      self.table_name = "users"

      devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

      def self.create_new(id: SecureRandom.uuid, email:, password:, first_name:, last_name:)
        new(
          id: id,
          email: email,
          password: password,
          first_name: first_name,
          last_name: last_name
        )
      end
    end
  end
end
