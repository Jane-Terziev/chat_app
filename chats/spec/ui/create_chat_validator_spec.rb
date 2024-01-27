require 'rails_helper'

RSpec.describe Chats::Ui::CreateChatValidator, type: :unit do
  describe '#.call(params)' do
    let(:params) do
      { 
        name: 'string',
        user_ids: [SecureRandom.uuid]
      }
    end

    context 'when all of the required parameters are present' do
      it 'should return success true' do
        expect(described_class.new.call(params).success?).to be_truthy
      end
    end

    context 'when the name parameter is missing' do
      it 'should raise an error' do
        expect(described_class.new.call(params.except(:name)).success?).to be_falsey
      end
    end

    context "when the user_ids parameter is missing" do
      it 'should raise an error' do
        expect(described_class.new.call(params.except(:user_ids)).success?).to be_falsey
      end
    end

    context "when the user_ids parameter is empty" do
      it 'should raise an error' do
        params[:user_ids] = []
        expect(described_class.new.call(params).success?).to be_falsey
      end
    end
  end
end
