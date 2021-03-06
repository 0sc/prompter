SAMPLE_AUTH_HASH = {
  provider: 'facebook',
  uid: '1234567',
  info: {
    email: 'joe@bloggs.com',
    name: 'Joe Bloggs',
    first_name: 'Joe',
    last_name: 'Bloggs',
    image: 'http://graph.facebook.com/1234567/picture?type=square',
    verified: true
  },
  credentials: {
    token: 'ABCDEF...',
    expires_at: 1_321_747_205,
    expires: true # this will always be true
  },
  extra: {
    raw_info: {
      id: '1234567',
      name: 'Joe Bloggs',
      first_name: 'Joe',
      last_name: 'Bloggs',
      link: 'http://www.facebook.com/jbloggs',
      username: 'jbloggs',
      location: { id: '123456789', name: 'Palo Alto, California' },
      gender: 'male',
      email: 'joe@bloggs.com',
      timezone: -8,
      locale: 'en_US',
      verified: true,
      updated_time: '2011-11-11T06:21:03+0000'
    }
  }
}.freeze

SAMPLE_MESSENGER_PROFILE = {
  'first_name' => 'Joe',
  'last_name' => 'Bloggs',
  'profile_pic' =>
  'https://platform-lookaside.fbsbx.com/platform/profilepic/?psid=987654321',
  'locale' => 'en_US',
  'timezone' => 1,
  'gender' => 'male',
  'id' => '987654321'
}.freeze

OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new(SAMPLE_AUTH_HASH)
