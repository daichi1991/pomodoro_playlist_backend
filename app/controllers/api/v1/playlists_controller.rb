class Api::V1::PlaylistsController < ApplicationController
  include SpotifyAuthUtils

  def current_user_playlists
    access_token = params[:access_token]

    uri = 'https://api.spotify.com/v1/me/playlists'
    authorization = 'Bearer ' + access_token

    request_spotify_api('GET', uri, authorization)
  end

  def get_playlist
    access_token = params[:access_token]
    playlist_id = params[:playlist_id]
    uri = 'https://api.spotify.com/v1/playlists/' + playlist_id
    authorization = 'Bearer ' + access_token

    request_spotify_api('GET', uri, authorization)
  end
end
