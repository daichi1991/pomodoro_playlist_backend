'require' 'securerandom'

FactoryBot.define do
  factory :user do
    spotify_id {SecureRandom.hex(10)}
  end
end
