require 'rails_helper'

RSpec.describe Chats::App::ChatService, type: :unit do
  subject(:chat_service) do
    described_class.new(chat_repository: chat_repository, current_user_repository: current_user_repository)
  end

  let(:chat_repository) { spy(Chats::Domain::Chat) }
  let(:current_user_repository) { spy(CurrentUserRepository) }
  let(:current_user) { instance_double(User) }
  let(:current_user_id) { SecureRandom.uuid }

  before do
    allow(current_user).to receive(:id) { current_user_id }
    allow(current_user_repository).to receive(:authenticated_identity) { current_user }
  end

  describe "#.create_chat(command)" do
    let(:command) do
      Chats::Ui::CreateChatValidator.command.new(
        id: SecureRandom.uuid,
        name: 'string',
        user_ids: [SecureRandom.uuid]
      )
    end

    context "when creating a new chat" do
      let(:chat) { instance_double(Chats::Domain::Chat, domain_events: []) }

      before do
        allow(chat_repository).to receive(:create_new) { chat }
        allow(chat_repository).to receive(:save!) { chat }
        allow(chat_service).to receive(:publish_all)
        allow(chat_service).to receive(:map_into)
      end

      it 'should call all the required model methods' do
        expect { chat_service.create_chat(command) }.to_not raise_error
        expect(chat_repository).to have_received(:create_new).with(
          name: command.name,
          user_ids: command.user_ids + [current_user_id],
          user_id: current_user_id
        )
        expect(chat_repository).to have_received(:save!).with(chat)
        expect(chat_service).to have_received(:publish_all).with(chat)
      end
    end
  end

  describe "#.delete_chat(id)" do
    let(:id) { SecureRandom.uuid }

    context "when the chat with the id is not found" do
      before do
        allow(chat_repository).to receive(:find) { raise ActiveRecord::RecordNotFound }
      end

      it 'should raise a ActiveRecord::RecordNotFound error' do
        expect { chat_service.delete_chat(id) }.to raise_error { ActiveRecord::RecordNotFound }
        expect(chat_repository).to have_received(:find).with(id)
      end
    end

    context "when the chat with the id is found" do
      let(:chat) { instance_double(Chats::Domain::Chat) }

      before do
        allow(chat_repository).to receive(:find) { chat }
        allow(chat).to receive(:delete_chat) { chat }
      end

      it 'should find the chat and delete it' do
        expect { chat_service.delete_chat(id) }.to_not raise_error
        expect(chat_repository).to have_received(:find).with(id)
        expect(chat_repository).to have_received(:delete!).with(chat)
      end
    end
  end
end