Dry::System.register_provider_source(:chats, group: :chats) do
  prepare do
    register("chats.chat_repository") { Chats::Domain::Chat }
    register("chats.message_repository") { Chats::Domain::Message }
    register("chats.unacknowledged_message_repository") { Chats::Domain::UnacknowledgedMessage }
    register('chats.chat_list_view_repository') { Chats::Domain::ReadModel::ChatListView }
    register('chats.message_list_view_repository') { Chats::Domain::ReadModel::MessageListView }
    register('chats.chat_participant_view_repository') { Chats::Domain::ReadModel::ChatParticipantView }
    register("chats.chat_service") { Chats::App::ChatService.new }
    register("chats.chat_read_service") { Chats::App::ReadModel::ChatService.new }
  end

  start do
    event_publisher = App::Container['events.publisher']

    event_publisher.subscribe(Chats::Ui::ChatListListener, to: [
      Chats::Domain::Chat::CreatedEvent,
      Chats::Domain::Chat::DeletedEvent,
      Chats::Domain::Chat::MessageSentEvent,
      Chats::Domain::Chat::MessageRemovedEvent,
      Chats::Domain::Chat::ChatParticipantAddedEvent,
      Chats::Domain::Chat::ChatParticipantRemovedEvent
    ])

    event_publisher.subscribe(Chats::Ui::ChatMessageListListener, to: [
      Chats::Domain::Chat::MessageSentEvent,
      Chats::Domain::Chat::MessageRemovedEvent,
      Chats::Domain::Chat::ChatParticipantRemovedEvent
    ])

    event_publisher.subscribe(Chats::Ui::ChatParticipantListListener, to: [
      Chats::Domain::Chat::ChatParticipantAddedEvent,
      Chats::Domain::Chat::ChatParticipantRemovedEvent
    ])

    event_publisher.subscribe(Chats::Ui::ChatCreatedNotifierListener, to: [
      Chats::Domain::Chat::CreatedEvent
    ])
  end
end

App::Container.register_provider(:chats, from: :chats)
App::Container.start(:chats)

