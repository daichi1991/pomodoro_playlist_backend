'require' 'securerandom'

FactoryBot.define do
  factory :pomodoro do
    association :user
    name { Faker::Lorem.word }
    work_time_playlist_id {SecureRandom.hex(10)}
    break_time_playlist_id {SecureRandom.hex(10)}
    work_time { Faker::Number.between(from: 1, to: 3600000) }
    break_time { Faker::Number.between(from: 1, to: 3600000) }
    term_count { Faker::Number.between(from: 1, to: 10) }
    long_break_time { Faker::Number.between(from: 1, to: 3600000) }
    term_repeat_count { Faker::Number.between(from: 1, to: 10) }
  end
end
