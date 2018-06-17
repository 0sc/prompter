Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :facebook,
    Rails.application.credentials.facebook_key,
    Rails.application.credentials.facebook_secret,
    scope: 'email,user_managed_groups,publish_to_groups,groups_access_member_info'
  )
end
