users = [
  User.create!(id: SecureRandom.uuid, email: "test1@example.com", password: "test123", first_name: "Name1", last_name: "LastName1"),
  User.create!(id: SecureRandom.uuid, email: "test2@example.com", password: "test123", first_name: "Name2", last_name: "LastName2")
]

user_ids = users.map(&:id)
user_id = users.first.id

10000.times do |i|
  Chats::Domain::Chat.create_new(name: "Chat #{i}", user_ids: user_ids, user_id: user_id).tap(&:save!)
end

chat = Chats::Domain::Chat.find_by(name: "Chat 0")

3000.times do |i|
  chat.send_message(message: "Message #{i}", user_id: user_id)
  chat.save!
end