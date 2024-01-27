require 'rails_helper'

RSpec.describe Chats::Ui::UpdateChatValidator, type: :unit do
  describe '#.call(params)' do
    let(:params) do
      { 
        name: 'string',
      }
    end

    context 'when all of the required parameters are present' do
      it 'should return success true' do
        expect(described_class.new.call(params).success?).to be_truthy
      end
    end

    context 'when a required parameter is missing' do 
      it 'should raise an error when name is missing' do
        expect(described_class.new.call(params.except(:name)).success?).to be_falsey
      end
    end
  end
end
