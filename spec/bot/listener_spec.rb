require 'rails_helper'

RSpec.describe Listener do
  FakeMessage = Struct.new(:sender, :recipient, :timestamp, :message)

  xdescribe 'Bot#on(message)' do
    it 'responds with a message' do
      expect(Listener::Bot).to receive(:deliver).with(fake_message, access_token: '')
      Facebook::Messenger::Bot.trigger(:message, fake_message)
    end
  end

  private

  def fake_message
    sender = {"id"=>"1234"}
    recipient = {"id"=>"5678"}
    timestamp = 1528049653543
    message = {"text"=>"Hello, world"}
    FakeMessage.new(sender, recipient, timestamp, message)
  end
end
