Dry::System.register_provider_source(:chats, group: :chats) do
  prepare do
    register("chats.chat_repository") { Chats::Domain::Chat }
    register("chats.chat_service") { Chats::App::ChatService.new }
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
      Chats::Domain::Chat::ChatParticipantRemovedEvent
    ])

    event_publisher.subscribe(Chats::Ui::ChatCreatedNotifierListener, to: [
      Chats::Domain::Chat::CreatedEvent
    ])
  end
end

App::Container.register_provider(:chats, from: :chats)
App::Container.start(:chats)

