require 'rails_helper'

RSpec.describe Chats::Ui::ParticipantsController, type: :controller do
  let(:current_user) do
    Authentication::Domain::User.create!(
      id: SecureRandom.uuid,
      email: "test@example.com",
      password: 'test123',
      first_name: "First Name",
      last_name: "Last Name"
    )
  end

  let(:other_user) do
    Authentication::Domain::User.create!(
      id: SecureRandom.uuid,
      email: "test2@example.com",
      password: 'test123',
      first_name: "First Name",
      last_name: "Last Name"
    )
  end

  let!(:chat) do
    Chats::Domain::Chat.create!(
      id: SecureRandom.uuid,
      name: 'string',
      chat_participants: [Chats::Domain::ChatParticipant.new(id: SecureRandom.uuid, user_id: current_user.id, status: 'active')]
    )
  end

  describe "POST #create" do
    context "when the user is not authenticated" do
      subject { post :create, params: { chat_id: chat.id, chat: { user_ids: [other_user.id] } } }

      it 'should redirect to sessions page' do
        subject

        expect(response.status).to eq(302)
        expect(response).to redirect_to(user_session_path)
      end
    end

    context "when the user is authenticated" do
      before do
        allow_any_instance_of(Chats::Ui::ParticipantsController).to receive(:authenticate_user!)
        allow_any_instance_of(Chats::Ui::ParticipantsController).to receive(:current_user) { current_user }
      end

      context 'and when the validation is valid' do
        subject { post :create, params: { chat_id: chat.id, chat: { user_ids: [other_user.id] } } }
        render_views

        it 'should add participant to chat' do
          expect(Chats::Domain::ChatParticipant.count).to eq(1)
          subject

          expect(response.status).to eq(201)
          expect(Chats::Domain::ChatParticipant.count).to eq(2)
        end
      end

      context "and when the validation is invalid" do
        subject { post :create, params: { chat_id: chat.id, chats: { test: '123' } } }

        it 'should return a form with an error' do
          subject
          expect(response.status).to eq(422)
          expect(response).to render_template 'chats/ui/participants/new'
        end
      end
    end
  end

  describe "DELETE #destroy" do
    before do
      chat.add_chat_participants(user_ids: [other_user.id])
      chat.save!
    end

    context "when the user is not authenticated" do
      subject { delete :destroy, params: { id: other_user.id, chat_id: chat.id } }

      it 'should redirect to sessions page' do
        subject

        expect(response.status).to eq(302)
        expect(response).to redirect_to(user_session_path)
      end
    end

    context "when the user is authenticated" do
      before do
        allow_any_instance_of(Chats::Ui::ParticipantsController).to receive(:authenticate_user!)
        allow_any_instance_of(Chats::Ui::ParticipantsController).to receive(:current_user) { current_user }
      end

      context 'when the chat is not found' do
        subject { delete :destroy, params: { id: other_user.id, chat_id: SecureRandom.uuid } }
        render_views

        it 'should raise a ActiveRecord::RecordNotFound error' do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'when the participant is not found' do
        subject { delete :destroy, params: { id: SecureRandom.uuid, chat_id: chat.id } }
        render_views

        it 'should raise a ActiveRecord::RecordNotFound error' do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when chat and participant exist" do
        subject { delete :destroy, params: { id: other_user.id, chat_id: chat.id } }
        render_views

        it 'should delete the message' do
          expect(Chats::Domain::ChatParticipant.where(status: 'active').count).to eq(2)

          subject

          expect(response.status).to eq(200)
          expect(Chats::Domain::ChatParticipant.where(status: 'active').count).to eq(1)
        end
      end
    end
  end
end