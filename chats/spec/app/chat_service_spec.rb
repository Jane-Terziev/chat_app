require 'rails_helper'

RSpec.describe Chats::App::ChatService, type: :unit do
  subject(:chat_service) do
    described_class.new(chat_repository: chat_repository, current_user_repository: current_user_repository)
  end

  let(:chat_repository) { spy(Chats::Domain::Chat) }
  let(:current_user_repository) { spy(CurrentUserRepository) }
  let(:current_user) { instance_double(User) }
  let(:current_user_id) { SecureRandom.uuid }
  let(:chat) { instance_double(Chats::Domain::Chat, id: SecureRandom.uuid, domain_events: []) }


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

  describe "#.send_message(command)" do
    let(:command) do
      Chats::Ui::SendMessageValidator.command.new(
        chat_id: SecureRandom.uuid,
        message: 'message',
        attachments: ['attachment']
      )
    end

    context 'when the chat is not found' do
      before do
        allow(chat_repository).to receive(:find) { raise ActiveRecord::RecordNotFound }
      end

      it 'should raise ActiveRecord::RecordNotFound' do
        expect { chat_service.send_message(command) }.to raise_error(ActiveRecord::RecordNotFound)
        expect(chat_repository).to have_received(:find).with(command.chat_id)
        expect(chat_repository).to_not have_received(:send_message)
      end
    end

    context "when the chat is found" do
      before do
        allow(chat_repository).to receive(:find) { chat }
        allow(chat).to receive(:send_message)
        allow(chat_repository).to receive(:save!) { chat }
        allow(chat_service).to receive(:publish_all)
      end

      it 'should add the message to the chat' do
        expect { chat_service.send_message(command) }.to_not raise_error
        expect(chat_repository).to have_received(:find).with(command.chat_id)
        expect(chat).to have_received(:send_message).with(
          message: command.message,
          attachments: command.attachments,
          user_id: current_user_id
        )
        expect(chat_repository).to have_received(:save!).with(chat)
        expect(chat_service).to have_received(:publish_all).with(chat)
      end
    end
  end

  describe "#.acknowledge_messages(chat_id)" do
    context "when the chat is not found" do
      before do
        allow(chat_repository).to receive(:find) { raise ActiveRecord::RecordNotFound }
      end

      it 'should raise ActiveRecord::RecordNotFound error' do
        expect { chat_service.acknowledge_messages(chat.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when the chat is found" do
      before do
        allow(chat_repository).to receive(:find) { chat }
        allow(chat).to receive(:acknowledge_messages)
        allow(chat_repository).to receive(:save!) { chat }
        allow(chat_service).to receive(:publish_all)
      end

      it 'should acknowledge the chat messages' do
        expect { chat_service.acknowledge_messages(chat.id) }.to_not raise_error
        expect(chat_repository).to have_received(:find).with(chat.id)
        expect(chat).to have_received(:acknowledge_messages).with(user_id: current_user_id)
        expect(chat_repository).to have_received(:save!).with(chat)
        expect(chat_service).to have_received(:publish_all).with(chat)
      end
    end
  end

  describe "#.remove_message(chat_id, message_id)" do
    let(:message_id) { SecureRandom.uuid }

    context "when the chat is not found" do
      before do
        allow(chat_repository).to receive(:find) { raise ActiveRecord::RecordNotFound }
      end

      it 'should raise ActiveRecord::RecordNotFound error' do
        expect { chat_service.remove_message(chat.id, message_id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when the chat is found" do
      before do
        allow(chat_repository).to receive(:find) { chat }
        allow(chat).to receive(:remove_message)
        allow(chat_repository).to receive(:save!) { chat }
        allow(chat_service).to receive(:publish_all)
        allow(chat_service).to receive(:map_into)
      end

      it 'should remove the message' do
        expect { chat_service.remove_message(chat.id, message_id) }.to_not raise_error
        expect(chat_repository).to have_received(:find).with(chat.id)
        expect(chat).to have_received(:remove_message).with(message_id: message_id, user_id: current_user_id)
        expect(chat_repository).to have_received(:save!).with(chat)
        expect(chat_service).to have_received(:publish_all).with(chat)
        expect(chat_service).to have_received(:map_into).with(chat, Chats::App::GetChatsListDto, { unread_messages: 0 })
      end
    end
  end

  describe "#.add_chat_participants(command)" do
    let(:command) { Chats::Ui::AddChatParticipantValidator.command.new(user_ids: [SecureRandom.uuid], chat_id: chat.id) }

    context "when the chat is not found" do
      before do
        allow(chat_repository).to receive(:find) { raise ActiveRecord::RecordNotFound }
      end

      it 'should raise ActiveRecord::RecordNotFound error' do
        expect { chat_service.add_chat_participants(command) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when the chat is found" do
      before do
        allow(chat_repository).to receive(:find) { chat }
        allow(chat).to receive(:add_chat_participants)
        allow(chat_repository).to receive(:save!) { chat }
        allow(chat_service).to receive(:publish_all)
        allow(chat_service).to receive(:map_into)
      end

      it 'should add the participants' do
        expect { chat_service.add_chat_participants(command) }.to_not raise_error
        expect(chat_repository).to have_received(:find).with(chat.id)
        expect(chat).to have_received(:add_chat_participants).with(user_ids: command.user_ids)
        expect(chat_repository).to have_received(:save!).with(chat)
        expect(chat_service).to have_received(:publish_all).with(chat)
        expect(chat_service).to have_received(:map_into).with(chat, Chats::App::GetChatParticipantDto)
      end
    end
  end

  describe "#.remove_chat_participant(chat_id, user_id)" do
    let(:user_id) { SecureRandom.uuid }
    context "when the chat is not found" do
      before do
        allow(chat_repository).to receive(:find) { raise ActiveRecord::RecordNotFound }
      end

      it 'should raise ActiveRecord::RecordNotFound error' do
        expect { chat_service.remove_chat_participant(chat.id, user_id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when the chat is found" do
      before do
        allow(chat_repository).to receive(:find) { chat }
        allow(chat).to receive(:remove_chat_participant)
        allow(chat_repository).to receive(:save!) { chat }
        allow(chat_service).to receive(:publish_all)
        allow(chat_service).to receive(:map_into)
      end

      it 'should add the participants' do
        expect { chat_service.remove_chat_participant(chat.id, user_id) }.to_not raise_error
        expect(chat_repository).to have_received(:find).with(chat.id)
        expect(chat).to have_received(:remove_chat_participant).with(user_id: user_id)
        expect(chat_repository).to have_received(:save!).with(chat)
        expect(chat_service).to have_received(:publish_all).with(chat)
        expect(chat_service).to have_received(:map_into).with(chat, Chats::App::GetChatParticipantDto)
      end
    end
  end

  describe "#.get_all_chats(query)" do
    let(:query) { Chats::Ui::ListQuery.new }
    let(:chat_list) { [instance_double(Chats::Domain::Chat)] }

    context "when getting a list of chats" do
      before do
        allow(chat_repository).to receive_message_chain(:joins, :where, :includes, :order, :ransack, :result) { chat_list }
        allow(chat_service).to receive(:map_into)
        allow(chat_service).to receive(:pagy_countless) { [Pagy.new(count: 1000, page: 10, size: 5), chat_list]  }
        chat_list.each { |chat| allow(chat).to receive(:unread_messages) }
      end

      it 'should return a mapped dto' do
        chat_service.get_all_chats(query)
        expect(chat_repository).to have_received(:joins).with(:chat_participants)
        expect(chat_repository.joins).to have_received(:where).with(chat_participants: { user_id: current_user_id })
        expect(chat_repository.joins.where).to have_received(:includes).with(:unacknowledged_messages)
        expect(chat_repository.joins.where.includes).to have_received(:order).with('updated_at DESC')
        expect(chat_repository.joins.where.includes.order).to have_received(:ransack).with(query.q)
        expect(chat_repository.joins.where.includes.order.ransack).to have_received(:result)
        chat_list.each do |chat|
          expect(chat).to have_received(:unread_messages).with(current_user_id)
          expect(chat_service).to have_received(:map_into).with(
            chat, Chats::App::GetChatsListDto,
            { unread_messages: chat.unread_messages(current_user_id) }
          )
        end
      end
    end
  end

  describe "#.get_chat(id)" do
    context "when the chat with the id is not found" do
      before do
        allow(chat_repository).to receive(:find) { raise ActiveRecord::RecordNotFound }
      end

      it 'should raise a ActiveRecord::RecordNotFound error' do
        expect { chat_service.get_chat(chat.id) }.to raise_error { ActiveRecord::RecordNotFound }
        expect(chat_repository).to have_received(:find).with(chat.id)
      end
    end

    context "when the chat is found" do
      before do
        allow(chat_repository).to receive_message_chain(:includes, :find) { chat }
        allow(chat).to receive(:acknowledge_messages)
        allow(chat_repository).to receive(:save!) { chat }
        allow(chat_service).to receive(:publish_all)
        allow(chat_service).to receive(:map_into)
      end

      it 'should return a chat details dto' do
        chat_service.get_chat(chat.id)
        expect(chat_repository).to have_received(:includes).with(
          :unacknowledged_messages,
          chat_participants: [:user, messages: [:attachments_attachments, :attachments_blobs] ]
        )
        expect(chat_repository.includes).to have_received(:find).with(chat.id)
        expect(chat).to have_received(:acknowledge_messages).with(user_id: current_user_id)
        expect(chat_repository).to have_received(:save!).with(chat)
        expect(chat_service).to have_received(:publish_all).with(chat)
        expect(chat_service).to have_received(:map_into).with(chat, Chats::App::GetChatDetailsDto)
      end
    end
  end
end