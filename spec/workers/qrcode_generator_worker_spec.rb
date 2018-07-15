require 'rails_helper'
RSpec.describe QrcodeGeneratorWorker, type: :worker do
  let(:community) { create(:community) }
  let(:qrcode) { 'https://some.image.url/on/cloudinary' }
  let(:base) { 'http://m.you' }
  let(:token) { 'page-access-token' }
  let(:dummy) { double }

  before do
    stub_const('HTTParty', dummy)
    stub_const('Cloudinary::Uploader', dummy)
    stub_const('QrcodeGeneratorWorker::MESSENGER_URL', base)
    stub_const('QrcodeGeneratorWorker::ATTACHMENT_URL', base)
    stub_const('ENV', 'PAGE_ACCESS_TOKEN' => token)
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

    expect(dummy)
      .to receive(:post).ordered.once.with(url, payload).and_return(response)
    expect(dummy).to receive(:upload)
      .with(resp_uri, folder: QrcodeGeneratorWorker::STORAGE_FOLDER)
      .and_return('secure_url' => qrcode)

    # upload to Facebook
    att_id = 12_345
    payload = {
      body: {
        message: {
          attachment: {
            type: 'image',
            payload: { is_reusable: true, url: qrcode }
          }
        }
      }
    }
    expect(dummy).to receive(:post)
      .ordered.once.with(url, payload).and_return('attachment_id' => att_id)
    # send notice to all admins
    no_psid = create(:community_admin_profile, community: community)
    no_psid.admin_profile.user.update!(psid: nil)
    create_list(:community_admin_profile, 2, community: community).each do |ad|
      psid = ad.admin_profile.user.psid
      expect(Notifier).to receive(:send_qrcode_notice)
        .ordered.once.with(attachment_id: att_id, psid: psid)
    end

    expect { QrcodeGeneratorWorker.drain }
      .to change { community.reload.qrcode }.to(qrcode)
  end
end
