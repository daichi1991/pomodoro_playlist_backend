module SpotifyAuthUtils
  extend ActiveSupport::Concern

  def spotify_auth_url
    state = generate_random_string(16)
    scope = 'user-read-private user-read-email'
    redirect_uri = 'http://localhost:3000/api/v1/users/callback'
    query_params = {
      response_type: 'code',
      client_id: ENV["SPOTIFY_CLIENT_ID"],
      scope: scope,
      state: state
    }
    "https://accounts.spotify.com/authorize?#{query_params.to_query}&redirect_uri=#{redirect_uri}"
  end

  def generate_random_string(length)
    characters = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
    random_string = ''
    
    length.times do
      random_string << characters.sample
    end
    
    random_string
  end

end