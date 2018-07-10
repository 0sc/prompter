require 'rails_helper'

RSpec.describe WitService, type: :service do
  let(:client) { double }
  let(:msg) { 'I like Golang if Ruby would not scale' }
  subject { WitService.new(msg, client: client) }
  let(:resp) do
    {
      '_text' => msg,
      'entities' => {
        'intent' => [
          { 'confidence' => 0.92690625261654, 'value' => 'programming-golang' },
          { 'confidence' => 0.72690625261654, 'value' => 'programming-ruby' }
        ]
      },
      'msg_id' => '0iH9kEzeEZ3OAxJXW'
    }
  end

  before(:each) do
    allow(client).to receive(:message)
      .with(an_instance_of(String))
      .and_return(resp)
  end

  describe '#analyse' do
    it 'returns the wit ai result for analysing the given msg' do
      expect(subject.analyse).to eq resp
    end
  end

  describe '#intent_value' do
    it 'returns the value of the intent with the highest confidence' do
      subject.analyse
      expect(subject.intent_value).to eq 'programming-golang'
    end
  end

  describe '#intent' do
    it 'returns the intent with the highest confidence' do
      subject.analyse
      expect(subject.intent).to eq resp.dig('entities', 'intent').first
    end
  end

  describe '#intents' do
    it 'returns an array of all the intents' do
      subject.analyse
      expect(subject.intents).to eq resp.dig('entities', 'intent')
    end
  end
end
