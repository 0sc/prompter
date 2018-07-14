module MessengerProfile
  FB_BASE = 'https://graph.facebook.com/v2.6'.freeze
  PROFILE_FIELDS = %w[first_name last_name profile_pic].freeze
  TOKEN_PLACEHOLDER = 'temp-token-for-account-from-psid'.freeze
  EMAIL_PLACEHOLDER_HOST = '@temp-email.io'.freeze

  def self.included(base)
    base.validates_uniqueness_of :psid, if: :psid
  end

  def update_from_psid!
    details = profile_details_from_messenger
    self.fbid ||= details['id']
    self.email ||= build_placeholder_email(details['id'])
    self.name ||= build_name(details['first_name'], details['last_name'])
    self.image = details['profile_pic']

    self.token ||= TOKEN_PLACEHOLDER
    self.expires_at ||= Time.zone.now

    save!
  end

  def first_name
    name.split.first
  end

  private

  def build_name(first_name, last_name)
    "#{first_name} #{last_name}"
  end

  def build_placeholder_email(profile_id)
    "#{profile_id}#{EMAIL_PLACEHOLDER_HOST}"
  end

  def placeholder_email?
    email.strip[/@.+/] == EMAIL_PLACEHOLDER_HOST
  end

  def placeholder_token?
    token == TOKEN_PLACEHOLDER
  end

  def profile_details_from_messenger
    url = "#{FB_BASE}/#{psid}?" \
          "field=#{PROFILE_FIELDS.join(',')}&" \
          "access_token=#{app_access_token}"
    HTTParty.get(url)
  end

  def app_access_token
    ENV.fetch('PAGE_ACCESS_TOKEN')
  end
end
