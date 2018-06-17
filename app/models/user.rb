class User < ApplicationRecord
  validates_presence_of :email, :fbid, :token, :expires_at
  validates_uniqueness_of :email, :fbid

  has_one :admin_profile
  has_one :member_profile

  def update_from_auth_hash(auth_hash)
    self.email = auth_hash[:info][:email]

    self.first_name = auth_hash[:info][:first_name]
    self.last_name = auth_hash[:info][:last_name]

    self.token = auth_hash[:credentials][:token]
    self.expires_at = auth_hash[:credentials][:expires_at]
  end

  def name
    "#{first_name} #{last_name}"
  end
end
