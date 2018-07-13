class QrcodeGeneratorWorker
  MESSENGER_URL = MessengerProfile::FB_BASE + '/me/messenger_codes'
  STORAGE_FOLDER = 'hermes/qrcodes'.freeze

  include Sidekiq::Worker

  def perform(community_id)
    community = Community.find_by(id: community_id)
    return unless community.present?
    # get code from FB
    messenger_code_url = generate_messenger_code(community)

    # upload to cloudinary
    cloudinary_url = upload_code_to_cloudinary(messenger_code_url)

    # update community
    community.update!(qrcode: cloudinary_url)
  end

  def generate_messenger_code(community)
    access_token = Rails.application.credentials.page_access_token
    url = MESSENGER_URL + "?access_token=#{access_token}"
    payload = {
      type: 'standard',
      data: { ref: community.referral_code },
      image_size: 1000
    }

    HTTParty.post(url, body: payload).dig('uri')
  end

  def upload_code_to_cloudinary(code_url)
    resp = Cloudinary::Uploader.upload(code_url, folder: STORAGE_FOLDER)
    resp['secure_url']
  end
end
