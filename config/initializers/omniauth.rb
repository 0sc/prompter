Rails.application.config.middleware.use OmniAuth::Builder do
  provider(:facebook, ENV.fetch('FACEBOOK_KEY'), ENV.fetch('FACEBOOK_SECRET'),
           scope: 'email,groups_access_member_info')
  # user_managed_groups
end
