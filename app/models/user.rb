class User < ApplicationRecord
  include MessengerProfile

  validates_presence_of :email, :fbid, :name, :token, :expires_at
  validates_uniqueness_of :email, :fbid

  has_one :admin_profile, dependent: :destroy
  has_one :member_profile, dependent: :destroy

  delegate :admin_communities, to: :admin_profile
  delegate :member_communities, :subscriptions?, to: :member_profile

  after_create :create_admin_profile!
  after_create :create_member_profile!

  def update_from_auth_hash(auth_hash)
    self.fbid = auth_hash.dig('uid')
    self.email = auth_hash.dig(:info, :email)
    self.name = auth_hash.dig(:info, :name)
    self.image = auth_hash.dig(:info, :image)

    self.token = auth_hash.dig(:credentials, :token)
    self.expires_at =
      auth_hash.dig(:credentials, :expires_at) || (Time.zone.now + 20.days).to_i
  end

  def account_linked?
    !(fbid == psid || placeholder_email? || placeholder_token?)
  end

  def token_expired?
    Time.zone.now > Time.zone.at(expires_at)
  end
end
