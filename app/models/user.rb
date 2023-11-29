class User < ApplicationRecord
  validates :spotify_id, presence: true, uniqueness: true
  has_many :pomodoros
end
