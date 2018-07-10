require 'rails_helper'
RSpec.describe MessengerNotificationWorker, type: :worker do
  subject { MessengerNotificationWorker }

  it 'enqueues the specified job' do
    mtd = 'send_community_added'
    args = [12, 13]
    subject.perform_async(mtd, 12, 13)

    expect(subject.jobs.size).to eq 1
    expect(subject.jobs.first['args']).to eq [mtd, *args]

    expect(MessengerNotificationService).to receive(mtd).with(*args)
    subject.drain
  end
end
