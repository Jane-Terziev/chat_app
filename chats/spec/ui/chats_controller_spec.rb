require 'rails_helper'

RSpec.describe Chats::Ui::ChatsController, type: :controller do
  let(:chat_service) { instance_double(Chats::App::ChatService) }
  let!(:chats) do
    [
      Chats::Domain::Chat.create!(
        id: SecureRandom.uuid,
        name: 'string',
      )
    ]
  end

  describe 'GET #index' do
    subject { get :index }
    render_views

    it 'renders the index template' do
      subject

      expect(response.status).to eq(200)
      expect(response).to render_template :index
      chats.each do |chat|
         expect(response.body).to include(chat.name.to_s)
      end
    end
  end

  describe 'GET #show' do
    context 'when the chat is not found' do
      subject { get :show, params: { id: SecureRandom.uuid } }
      render_views

      it 'should raise an ActiveRecord::RecordNotFound error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when the chat is found" do
      subject { get :show, params: { id: chats[0].id } }
      render_views

      it 'renders the show template' do
        subject

        expect(response.status).to eq(200)
        expect(response).to render_template :show

      chats.each do |chat|
         expect(response.body).to include(chats[0].name.to_s)
        end
      end
    end
  end

  describe 'GET #new' do
    subject { get :new }
    render_views

    it 'renders the new template' do
      subject

      expect(response.status).to eq(200)
      expect(response).to render_template :new
    end
  end

  describe 'GET #edit' do
    context 'when the chat is not found' do
      subject { get :edit, params: { id: SecureRandom.uuid } }
      render_views

      it 'should raise an ActiveRecord::RecordNotFound error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the chat is found' do
      subject { get :edit, params: { id: chats[0].id } }
      render_views

      it 'renders the edit template' do
        subject

        expect(response.status).to eq(200)
        expect(response).to render_template :edit
      end
    end
  end

  describe "POST #create" do
    context 'when the validation is valid' do
      subject do
        post :create,
        params: {
          chat: {
            name: 'string',
          }
        }
      end
      render_views

      it 'should create a new chat' do
        expect(Chats::Domain::Chat.count).to eq(1)

        subject

        expect(response.status).to eq(302)
        expect(Chats::Domain::Chat.count).to eq(2)
      end
    end

    context 'when the validation is not valid' do
      subject do
        post :create,
        params: {
          chat: {
          }
        }
      end
      render_views

      it 'should render the new template with status 422' do
        subject

        expect(response.status).to eq(422)
        expect(response).to render_template :new
      end
    end
  end

  describe "PATCH #update" do
    let(:params) do
      {
        id: chats[0].id,
        chat: {
          name: 'string',
        }
      }
    end

    context 'when the validation is not valid' do
      subject do
        patch :update,
        params: {
          id: chats[0].id,
          chat: {
          }
        }
      end
      render_views

      it 'should render the edit template with status 422' do
        subject

        expect(response.status).to eq(422)
        expect(response).to render_template :edit
      end
    end

    context "when the chat is not found" do
      subject { patch :update, params: params.merge(id: SecureRandom.uuid) }
      render_views

      it 'should raise an ActiveRecord::RecordNotFound error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when the chat is found" do
      subject { patch :update, params: params }
      render_views

      it 'should update the chat' do
        subject

        chat = Chats::Domain::Chat.last

        expect(response.status).to eq(302)
        expect(chat.name).to eq(params[:chat][:name])
      end
    end
  end

  describe 'DELETE #destroy' do
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
        expect(response.status).to eq(302)
      end
    end
  end
end