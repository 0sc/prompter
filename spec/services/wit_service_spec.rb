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

  describe '#initialize' do
    it 'truncates the message to 280 chars' do
      msg = <<-TXT
      #IssaGoallllllllllllllll\n\nHello People! \nIt feels good to see how we help each other here by providing answers to questions, helping to point newbies to helpful documents and learning platforms. This is what we want this community to be - The most engaging and helpful Developer Circle in the world, Yea we are doing that already.\n\nTo everyone helping to provide guides to the newbies in the house, those who read something interesting about Tech and consider it thoughtful to share with the community, those who make interesting findings from their personal experiments and decide to share with us and to all who in one way or the other help to keep this community active and helpful, I say Kudos to you all. You make DevC Lagos thick!!!\n\nOn the flip-side, we have observed the rise of unwanted posts, particularly those marketing Web development courses, WhatsApp groups, Facebook groups. \nAs much as these courses are Tech related, we do not allow any form of marketing here. Any such posts will be deleted (kindly refer to the pinned post for details). \n\nFeel free to share your knowledge with us right here or contact Peculiar Ediomo-Abasi and @Oluebube Princess Egbuna to help with posting on the community's medium page. \nWe are not against monetizing your skills but such is not allowed here. \n\n#Peace!!!
      TXT

      svc = WitService.new(msg, client: client)
      expect(svc.msg)
        .to eq msg.truncate(WitService::MAX_CHARS, separator: '.', omission: '')
    end
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
