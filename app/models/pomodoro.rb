class Pomodoro < ApplicationRecord
  validates :user_id, presence: true
  validates :name, presence: true
  validates :work_time_playlist_id, presence: true
  validates :break_time_playlist_id, presence: true
  validates :work_time, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :break_time, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :term_count, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :long_break_time, presence: true, numericality: { only_integer: true, greater_than: 0 }
  
  belongs_to :user
end
