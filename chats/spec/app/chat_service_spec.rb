require 'rails_helper'

RSpec.describe Chats::App::ChatService, type: :unit do
  subject(:chat_service) do
    described_class.new(chat_repository: chat_repository)
  end

  let(:chat_repository) { spy(Chats::Domain::Chat) }

  describe "#.create_chat(command)" do
    let(:command) do
      Chats::Ui::CreateChatValidator.command.new(
        name: 'string',
        id: SecureRandom.uuid
      )
    end

    context "when creating a new chat" do
      it 'should call all the required model methods' do
        expect { chat_service.create_chat(command) }.to_not raise_error
        expect(chat_repository).to have_received(:create!).with(command.to_h)
      end
    end
  end

  describe "#.update_chat(command)" do
    let(:command) do
      Chats::Ui::UpdateChatValidator.command.new(
        name: 'string',
        id: SecureRandom.uuid
      )
    end

    context "when the chat with the id is not found" do
      before do
        allow(chat_repository).to receive(:find) { raise ActiveRecord::RecordNotFound }
      end

      it 'should raise a ActiveRecord::RecordNotFound error' do
        expect { chat_service.update_chat(command) }.to raise_error { ActiveRecord::RecordNotFound }
      end
    end

    context "when the chat with the id is found" do
      let(:chat) { instance_double(Chats::Domain::Chat) }

      before do
        allow(chat_repository).to receive(:find) { chat }
        allow(chat).to receive(:update!)
      end

      it 'should update the record' do
        expect { chat_service.update_chat(command) }.to_not raise_error
        expect(chat_repository).to have_received(:find).with(command.id)
        expect(chat).to have_received(:update!).with(command.to_h)
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
      end

      it 'should find the chat and delete it' do
        expect { chat_service.delete_chat(id) }.to_not raise_error
        expect(chat_repository).to have_received(:find).with(id)
        expect(chat_repository).to have_received(:delete!).with(chat)
      end
    end
  end
end