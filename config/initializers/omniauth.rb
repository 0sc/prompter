Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :facebook,
    Rails.application.credentials.facebook_key,
    Rails.application.credentials.facebook_secret,
    scope: 'email,publish_to_groups,groups_access_member_info' #user_managed_groups
  )
end
