require 'rails_helper'

RSpec.describe Client do
  let(:bot) { Facebook::Messenger::Bot }

  before do
    allow(Client).to receive(:access_token).and_return(987)
  end

  describe '.respond' do
    it 'delivers the given payload to the given psid' do
      expect(bot).to receive(:deliver)
        .with({ recipient: { id: 123 }, hello: 'world' }, access_token: 987)

      Client.respond(123, hello: 'world')
    end
  end
end
