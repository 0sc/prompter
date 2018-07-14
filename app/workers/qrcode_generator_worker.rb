class QrcodeGeneratorWorker
  MESSENGER_URL = MessengerProfile::FB_BASE + '/me/messenger_codes'
  ATTACHMENT_URL = MessengerProfile::FB_BASE + '/me/message_attachments'
  STORAGE_FOLDER = 'prompter/qrcodes'.freeze

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

    # upload to facebook
    attachment_id = upload_attachment_to_facebook(cloudinary_url)
    notify_community_admins(community, attachment_id)
  end

  def generate_messenger_code(community)
    url = append_access_token(MESSENGER_URL)
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

  def upload_attachment_to_facebook(qrcode_img_url)
    url = append_access_token(ATTACHMENT_URL)
    payload = {
      message: {
        attachment: {
          type: 'image',
          payload: { is_reusable: true, url: qrcode_img_url }
        }
      }
    }

    HTTParty.post(url, body: payload)['attachment_id']
  end

  def notify_community_admins(community, attachment_id)
    community.admin_profiles.find_each do |admin|
      Notifier
        .send_qrcode_notice(psid: admin.user.psid, attachment_id: attachment_id)
    end
  end

  def append_access_token(url)
    access_token = ENV.fetch('PAGE_ACCESS_TOKEN')
    url + "?access_token=#{access_token}"
  end
end
