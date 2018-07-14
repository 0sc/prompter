require 'rails_helper'
RSpec.describe QrcodeGeneratorWorker, type: :worker do
  let(:community) { create(:community) }
  let(:qrcode) { 'https://some.image.url/on/cloudinary' }
  let(:base) { 'http://m.you' }
  let(:dummy) { double }

  before do
    stub_const('HTTParty', dummy)
    stub_const('Cloudinary::Uploader', dummy)
    stub_const('QrcodeGeneratorWorker::MESSENGER_URL', base)
  end

  it 'returns nil if the community does not exist' do
    QrcodeGeneratorWorker.perform_async(404)

    expect(QrcodeGeneratorWorker.jobs.size).to eq 1
    expect(QrcodeGeneratorWorker.jobs.first['args']).to match_array([404])

    expect(QrcodeGeneratorWorker.drain).to be nil
  end

  it 'saves a new image for valid communities' do
    QrcodeGeneratorWorker.perform_async(community.id)

    expect(QrcodeGeneratorWorker.jobs.size).to eq 1
    expect(QrcodeGeneratorWorker.jobs[0]['args']).to match_array [community.id]

    url = base + '?access_token=' + token
    payload = {
      body: {
        type: 'standard',
        data: { ref: community.referral_code },
        image_size: 1000
      }
    }
    resp_uri = 'https://m.me/temp/qrcode/link.png'
    response = { 'uri' => resp_uri }

    expect(dummy).to receive(:post).with(url, payload).and_return(response)
    expect(dummy).to receive(:upload)
      .with(resp_uri, folder: QrcodeGeneratorWorker::STORAGE_FOLDER)
      .and_return('secure_url' => qrcode)

    expect { QrcodeGeneratorWorker.drain }
      .to change { community.reload.qrcode }.to(qrcode)
  end

  def token
    Rails.application.credentials.page_access_token
  end
end
