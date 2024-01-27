require 'rails_helper'

RSpec.describe Chats::Ui::ChatsController, type: :controller do
  let(:chat_service) { instance_double(Chats::App::ChatService) }
  let!(:chats) { [Chats::Domain::Chat.create!(id: SecureRandom.uuid, name: 'string')] }
  let(:current_user) do
    User.create!(
      id: SecureRandom.uuid,
      email: "test@example.com",
      password: 'test123',
      first_name: "First Name",
      last_name: "Last Name"
    )
  end

  describe 'GET #index' do

    subject { get :index }
    render_views

    context "when the user is not authenticated" do
      it 'should redirect to the sessions page' do
        subject

        expect(response.status).to eq(302)
        expect(response).to redirect_to(user_session_path)
      end
    end

    context "when the user is authenticated" do
      before do
        allow_any_instance_of(Chats::Ui::ChatsController).to receive(:authenticate_user!)
        allow_any_instance_of(Chats::Ui::ChatsController).to receive(:current_user) { current_user }
      end

      it 'renders the index template' do
        subject

        expect(response.status).to eq(200)
        expect(response).to render_template :index
      end
    end
  end

  describe "POST #create" do
    let(:users) do
      [
        User.create!(
          id: SecureRandom.uuid,
          email: "test1@example.com",
          password: 'test123',
          first_name: "First Name",
          last_name: "Last Name"
        )
      ]
    end

    context "when the user is not authenticated" do
      subject { post :create, params: { chat: { name: 'string', user_ids: users.map(&:id) } } }

      it 'should redirect to sessions page' do
        subject

        expect(response.status).to eq(302)
        expect(response).to redirect_to(user_session_path)
      end
    end

    context "when the user is authenticated" do
      before do
        allow_any_instance_of(Chats::Ui::ChatsController).to receive(:authenticate_user!)
        allow_any_instance_of(Chats::Ui::ChatsController).to receive(:current_user) { current_user }
      end

      context 'and when the validation is valid' do
        subject { post :create, params: { chat: { name: 'string', user_ids: users.map(&:id) } } }

        render_views

        it 'should create a new chat' do
          expect(Chats::Domain::Chat.count).to eq(1)

          subject

          expect(response.status).to eq(201)
          expect(Chats::Domain::Chat.count).to eq(2)
        end
      end

      context "and when the validation is invalid" do
        subject { post :create, params: { chat: { name: 'string' } } }

        it 'should return a form with an error' do
          expect(Chats::Domain::Chat.count).to eq(1)

          subject
          expect(response.status).to eq(422)
          expect(response).to render_template 'chats/ui/chats/_form'
          expect(Chats::Domain::Chat.count).to eq(1)
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    context "when the user is not authenticated" do
      subject { delete :destroy, params: { id: chats[0].id } }
      render_views

      it 'should redirect to the sessions page' do
        subject

        expect(response.status).to eq(302)
        expect(response).to redirect_to(user_session_path)
      end
    end

    context "when the user is authenticated" do
      before do
        allow_any_instance_of(Chats::Ui::ChatsController).to receive(:authenticate_user!)
        allow_any_instance_of(Chats::Ui::ChatsController).to receive(:current_user) { current_user }
      end

      context 'when the chat is not found' do
        subject { delete :destroy, params: { id: SecureRandom.uuid } }
        render_views

        it 'should raise a ActiveRecord::RecordNotFound error' do
          expect(Chats::Domain::Chat.count).to eq(1)

          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)

          expect(Chats::Domain::Chat.count).to eq(1)
        end
      end

      context "when the chat is found" do
        subject { delete :destroy, params: { id: chats[0].id } }
        render_views

        it 'should delete the chat' do
          expect(Chats::Domain::Chat.count).to eq(1)

          subject

          expect(Chats::Domain::Chat.count).to eq(0)
          expect(response.status).to eq(200)
        end
      end
    end
  end
end