require 'rails_helper'

RSpec.describe Chats::Ui::SendMessageValidator, type: :unit do
  describe '#.call(params)' do
    let(:params) do
      {
        message: 'string',
        attachments: ['test']
      }
    end

    context 'when all of the required parameters are present' do
      it 'should return success true' do
        expect(described_class.new.call(params).success?).to be_truthy
      end
    end

    context "when a message is sent and the attachments is not sent" do
      it 'should return success true' do
        expect(described_class.new.call(params.except(:attachments)).success?).to be_truthy
      end
    end

    context "when a message is not sent and the attachments is sent" do
      it 'should return success true' do
        expect(described_class.new.call(params.except(:message)).success?).to be_truthy
      end
    end

    context "when a message is not sent and the attachments is not sent" do
      it 'should return success false' do
        expect(described_class.new.call(params.except(:message, :attachments)).success?).to be_falsey
      end
    end

    context "when a message is not sent and the attachments is sent as empty" do
      it 'should return success false' do
        params[:attachments] = []
        expect(described_class.new.call(params.except(:message)).success?).to be_falsey
      end
    end
  end
end
