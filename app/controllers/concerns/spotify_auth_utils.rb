module SpotifyAuthUtils
  extend ActiveSupport::Concern

  def spotify_auth_url
    state = generate_random_string(16)
    scope = 'user-read-private user-read-playback-state user-read-email streaming playlist-read-private user-modify-playback-state user-read-currently-playing'
    redirect_uri = 'http://localhost:3001'
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

  def request_spotify_api(request_type, uri, authorization = nil, request_body = nil)
    auth_options = {
      uri: uri,
      body: request_body,
      headers: {
        Authorization: authorization
      },
      json: true
    }

    uri = URI.parse(auth_options[:uri])
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri.path) if request_type == 'GET'
    request = Net::HTTP::Post.new(uri.path) if request_type == 'POST'

    request.set_form_data(auth_options[:body]) if request_body
    request['Authorization'] = auth_options[:headers][:Authorization] if authorization

    response = http.request(request)
    response_body = JSON.parse(response.body)
  end

end