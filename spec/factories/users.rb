FactoryBot.define do
  factory :user do
    first_name 'John'
    last_name 'Doe'
    email 'john.doe@email.com'
    uid 123_456_789
    image 'http://graph.facebook.com/1234567/picture?type=square'
    token 'tooookeeeennnnnn'
    expires_at 1_321_747_205
  end
end
