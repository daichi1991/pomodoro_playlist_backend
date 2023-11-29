# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

user = User.find_or_create_by(
  spotify_id: 'abcdef12345'
)

pomodoro = Pomodoro.find_or_create_by(
  user_id: user.id,
  name: 'My Pomodoro',
  work_time_playlist_id: '1234567890',
  break_time_playlist_id: '0987654321',
  work_time: 25,
  break_time: 5,
  term_count: 4,
  long_break_time: 15
)
