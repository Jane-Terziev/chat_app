require 'rails_helper'

RSpec.describe Chats::App::ReadModel::ChatService, type: :unit do
  subject(:chat_service) do
    described_class.new(
      current_user_repository: current_user_repository,
      chat_list_view_repository: chat_list_view_repository,
      message_list_view_repository: message_list_view_repository,
      chat_participant_view_repository: chat_participant_view_repository,
      user_repository: user_repository,
      chat_message_link_repository: chat_message_link_repository
    )
  end

  let(:current_user_repository) { spy(CurrentUserRepository) }
  let(:chat_list_view_repository) { spy(Chats::Domain::ReadModel::ChatListView) }
  let(:message_list_view_repository) { spy(Chats::Domain::ReadModel::MessageListView) }
  let(:chat_participant_view_repository) { spy(Chats::Domain::ReadModel::ChatParticipantView) }
  let(:user_repository) { spy(Chats::Domain::User) }
  let(:chat_message_link_repository) { spy(Chats::Domain::ChatMessageLink) }
  let(:user) { instance_double(Authentication::Domain::User, id: SecureRandom.uuid) }
  let(:pagination) { Pagy.new(count: 1000, page: 10, size: 5) }

  before do
    allow(current_user_repository).to receive(:authenticated_identity) { user }
  end

  describe "#.get_all_chats(query)" do
    let(:query) { Chats::Ui::ListQuery.new }
    let(:chat) do
      Chats::Domain::ReadModel::ChatListView.new(
        id: SecureRandom.uuid,
        user_id: user.id,
        name: 'Chat Name',
        last_message: "Last Chat Message",
        unread_messages_count: 1,
        total_messages_count: 5,
        last_message_timestamp: DateTime.now
      )
    end
    let(:chat_list) { [chat] }
    let(:expected_result) do
      PaginationDto.new(
        data: [
          {
            "id" => chat.id,
            "name" => chat.name,
            "last_message" => chat.last_message,
            "unread_messages_count" => chat.unread_messages_count,
            "total_messages_count" => chat.total_messages_count,
            "last_message_timestamp" => chat.last_message_timestamp.to_datetime
          }
        ],
        pagination: pagination
      )
    end

    context "when getting a list of chats" do
      before do
        allow(chat_list_view_repository).to receive_message_chain(:where, :order, :ransack, :result) { chat_list }
        allow(chat_service).to receive(:pagy_countless) { [pagination, chat_list]  }
      end

      it 'should return a mapped dto' do
        result = chat_service.get_all_chats(query)
        expect(chat_list_view_repository).to have_received(:where).with(user_id: user.id)
        expect(chat_list_view_repository.where).to have_received(:order).with('last_message_timestamp DESC NULLS LAST, updated_at DESC NULLS LAST')
        expect(chat_list_view_repository.where.order).to have_received(:ransack).with(query.q)
        expect(chat_list_view_repository.where.order.ransack).to have_received(:result)
        expect(result.as_json).to eq(expected_result.as_json)
      end
    end
  end

  describe "#.get_chat(query)" do
    let(:query) { Chats::Ui::MessageListQuery.new(chat_id: SecureRandom.uuid) }

    context "when the chat with the id is not found" do
      before do
        allow(chat_list_view_repository).to receive(:find_by!) { raise ActiveRecord::RecordNotFound }
      end

      it 'should raise a ActiveRecord::RecordNotFound error' do
        expect { chat_service.get_chat(query) }.to raise_error { ActiveRecord::RecordNotFound }
        expect(chat_list_view_repository).to have_received(:find_by!).with(id: query.chat_id, user_id: user.id)
      end
    end

    context "when the chat is found" do
      let(:messages)  { [spy(Chats::Domain::Message)] }
      let(:chat) { instance_double(Chats::Domain::ReadModel::ChatListView) }

      before do
        allow(chat_list_view_repository).to receive(:find_by!) { chat }
        allow(chat_service).to receive(:pagy_countless) { [Pagy.new(count: 1000, page: 10, size: 5), messages] }
        allow(chat_service).to receive(:map_into)
      end

      it 'should return a chat details dto' do
        chat_service.get_chat(query)
        expect(chat_list_view_repository).to have_received(:find_by!).with(id: query.chat_id, user_id: user.id)
      end
    end
  end

  describe '#.get_chat_list_dto(chat_id)' do
    let(:chat_id) { SecureRandom.uuid }

    context "when the chat list item is not found" do
      before do
        allow(chat_list_view_repository).to receive(:find_by!) { raise ActiveRecord::RecordNotFound }
      end

      it 'should raise record not found error' do
        expect { chat_service.get_chat_list_dto(chat_id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when the chat list is found" do
      let(:chat) do
        Chats::Domain::ReadModel::ChatListView.new(
          id: chat_id,
          user_id: user.id,
          name: 'Chat Name',
          last_message: "Last Chat Message",
          unread_messages_count: 1,
          total_messages_count: 5,
          last_message_timestamp: DateTime.now,
        )
      end

      let(:expected_result) do
        {
          "id" => chat.id,
          "name" => chat.name,
          "last_message" => chat.last_message,
          "unread_messages_count" => chat.unread_messages_count,
          "total_messages_count" => chat.total_messages_count,
          "last_message_timestamp" => chat.last_message_timestamp.to_datetime
        }
      end

      before do
        allow(chat_list_view_repository).to receive(:find_by!) { chat }
      end

      it 'should return a GetChatsListDto' do
        result = chat_service.get_chat_list_dto(chat_id)
        expect(chat_list_view_repository).to have_received(:find_by!).with(id: chat_id, user_id: user.id)
        expect(result.as_json).to eq(expected_result.as_json)
      end
    end
  end

  describe '#.get_messages_dto(message_ids)' do
    context "when the message_ids that are sent exist" do
      let(:message) do
        Chats::Domain::ReadModel::MessageListView.new(
          id: SecureRandom.uuid,
          message: 'Message',
          user_id: SecureRandom.uuid,
          chat_id: SecureRandom.uuid,
          created_at: DateTime.now
        )
      end

      let(:messages) { [message] }

      let(:expected_result) do
        [
          {
            id: message.id,
            message: message.message,
            user_id: message.user_id,
            chat_id: message.chat_id,
            attachment_file: nil,
            created_at: message.created_at.to_datetime
          }
        ]
      end

      before do
        allow(message_list_view_repository).to receive(:where) { messages }
      end

      it 'should map them into a MessageDto' do
        result = chat_service.get_messages_dto(messages.map(&:id))
        expect(message_list_view_repository).to have_received(:where).with(id: messages.map(&:id))
        expect(result.as_json).to eq(expected_result.as_json)
      end
    end
  end

  describe '#.get_links_from_chat(query)' do
    let(:query) { Chats::Ui::LinksListQuery.new(chat_id: SecureRandom.uuid) }
    let(:chat_link) do
      Chats::Domain::ChatMessageLink.new(
        id: SecureRandom.uuid,
        message_id: SecureRandom.uuid,
        link: 'somelink.com'
      )
    end

    let(:chat_links_list) { [chat_link] }

    context "when getting a list of chat links" do
      let(:expected_result) do
        PaginationDto.new(
          data: [
            {
              "id" => chat_link.id,
              "message_id" => chat_link.message_id,
              "link" => chat_link.link
            }
          ],
          pagination: pagination
        )
      end
      before do
        allow(chat_message_link_repository).to receive_message_chain(:joins, :where, :order) { chat_links_list }
        allow(chat_service).to receive(:pagy_countless) { [Pagy.new(count: 1000, page: 10, size: 5), chat_links_list] }
      end

      it 'should return a pagination dto' do
        result = chat_service.get_links_from_chat(query)
        expect(chat_message_link_repository).to have_received(:joins).with(:message)
        expect(chat_message_link_repository.joins).to have_received(:where).with(message: { chat_id: query.chat_id })
        expect(chat_message_link_repository.joins.where).to have_received(:order).with('created_at DESC')
        expect(result.as_json).to eq(expected_result.as_json)
      end
    end
  end

  describe '#.get_active_chat_participants(chat_id)' do
    let(:chat_id) { SecureRandom.uuid }
    let(:chat_participant) do
      Chats::Domain::ReadModel::ChatParticipantView.new(
        id: SecureRandom.uuid,
        user_id: SecureRandom.uuid,
        chat_id: SecureRandom.uuid,
        first_name: "First Name",
        last_name: "Last Name",
        status: 'active'
      )
    end

    let(:chat_participants) { [chat_participant] }

    context "when getting a list of active chat participants" do
      let(:expected_result) do
        [
          {
            id: chat_participant.id,
            user_id: chat_participant.user_id,
            chat_id: chat_participant.chat_id,
            first_name: chat_participant.first_name,
            last_name: chat_participant.last_name,
            status: chat_participant.status
          }
        ]
      end

      before do
        allow(chat_participant_view_repository).to receive(:where) { chat_participants }
      end

      it 'should return chat participant dtos' do
        result = chat_service.get_active_chat_participants(chat_id)
        expect(chat_participant_view_repository).to have_received(:where).with(chat_id: chat_id, status: 'active')
        expect(result.as_json).to eq(expected_result.as_json)
      end
    end
  end

  describe "#.get_participants_select_options_for_new_chat" do
    let(:user) do
      Authentication::Domain::User.new(
        id: SecureRandom.uuid,
        first_name: "First Name",
        last_name: "Last Name"
      )
    end

    let(:users) { [user] }

    before do
      allow(user_repository).to receive_message_chain(:where, :not) { users }
    end

    context "when getting participant select options for creating new chat" do
      let(:expected_result) do
        [
          {
            id: user.id,
            first_name: user.first_name,
            last_name: user.last_name
          }
        ]
      end

      it 'should return select dtos' do
        result = chat_service.get_participants_select_options_for_new_chat
        expect(result.as_json).to eq(expected_result.as_json)
      end
    end
  end
end
