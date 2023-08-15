class Api::V1::UsersController < ApplicationController
  include SpotifyAuthUtils

  def login
    login_url = spotify_auth_url
    render json: { login: login_url }
  end

  def callback
    code = params[:code] || nil
    state = params[:state] || nil

    if state.nil?
      redirect '/#' + URI.encode_www_form(error: 'state_mismatch')
    else
      redirect_uri = 'http://localhost:3000/api/v1/users/callback'
      client_id = ENV["SPOTIFY_CLIENT_ID"]
      client_secret = ENV["SPOTIFY_CLIENT_SECRET"]

      uri = 'https://accounts.spotify.com/api/token'
      authorization = 'Basic ' + Base64.strict_encode64("#{client_id}:#{client_secret}")
      request_body = {
        code: code,
        redirect_uri: redirect_uri,
        grant_type: 'authorization_code'
      }
      request_spotify_api('POST', uri, authorization, request_body)

    end
  end

  def refresh_token
    client_id = ENV["SPOTIFY_CLIENT_ID"]
    client_secret = ENV["SPOTIFY_CLIENT_SECRET"]

    refresh_token = params[:refresh_token]

    uri = 'https://accounts.spotify.com/api/token'
    authorization = 'Basic ' + Base64.strict_encode64("#{client_id}:#{client_secret}")
    request_body = {
      grant_type: 'refresh_token',
      refresh_token: refresh_token
    }

    request_spotify_api('POST', uri, authorization, request_body)
  end

  def profile
    access_token = params[:access_token]

    uri = 'https://api.spotify.com/v1/me'
    authorization = 'Bearer ' + access_token

    request_spotify_api('GET', uri, authorization)
  end
end
