class User < ApplicationRecord
  validates_presence_of :email, :fbid, :name, :token, :expires_at
  validates_uniqueness_of :email, :fbid

  # has_one :admin_profile
  # has_one :member_profile

  def update_from_auth_hash(auth_hash)
    self.email = auth_hash[:info][:email]
    self.name = auth_hash[:info][:name]

    self.token = auth_hash[:credentials][:token]
    self.expires_at = auth_hash[:credentials][:expires_at]
  end
end
