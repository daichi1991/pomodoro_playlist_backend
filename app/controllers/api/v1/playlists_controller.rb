class Api::V1::PlaylistsController < ApplicationController
  def current_user_playlists
    access_token = params[:access_token]
    
    auth_options = {
      uri: 'https://api.spotify.com/v1/me/playlists',
      headers: {
        Authorization: 'Bearer ' + params[:access_token]
      },
      json: true
    }

    uri = URI.parse(auth_options[:uri])
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri.path)
    request['Authorization'] = auth_options[:headers][:Authorization]
  
    response = http.request(request)
    response_body = JSON.parse(response.body)
    render json: { response_body: response_body }
  end

  def get_playlist
    playlist_id = params[:playlist_id]
  end
end
