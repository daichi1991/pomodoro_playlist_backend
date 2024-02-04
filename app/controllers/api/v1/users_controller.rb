class Api::V1::UsersController < ApplicationController
  include SpotifyAuthUtils

  def login
    login_url = spotify_auth_url
    render json: { login_url: login_url }
  end

  def get_tokens
    code = params[:code]
    state = params[:state]
    refresh_token = get_refresh_token(code, state)
    access_token_response = get_access_token(refresh_token)
    access_token = access_token_response['access_token']
    render json: { refresh_token: refresh_token, access_token: access_token }, status: :ok
  end

  def refresh_token
    refresh_token = params[:refresh_token]
    logger.debug "refresh_token: #{refresh_token}"
    if refresh_token.nil? || refresh_token.empty? || refresh_token.blank?
      render json: { error: 'refresh_token not found' }, status: :bad_request
      return
    end
    access_token_response = get_access_token(refresh_token)
    render json: { data: access_token_response }, status: :ok
  end

  private

  def get_refresh_token(code, state)
    if state.nil?
      redirect '/#' + URI.encode_www_form(error: 'state_mismatch')
    else
      redirect_uri = ENV['FRONTEND_ORIGIN']
      client_id = ENV["SPOTIFY_CLIENT_ID"]
      client_secret = ENV["SPOTIFY_CLIENT_SECRET"]

      uri = 'https://accounts.spotify.com/api/token'
      authorization = 'Basic ' + Base64.strict_encode64("#{client_id}:#{client_secret}")
      request_body = {
        code: code,
        redirect_uri: redirect_uri,
        grant_type: 'authorization_code'
      }
      refresh_token_response = request_spotify_api('POST', uri, authorization, request_body)
      refresh_token = refresh_token_response['refresh_token']
    end
  end

  def get_access_token(refresh_token)
    client_id = ENV["SPOTIFY_CLIENT_ID"]
    client_secret = ENV["SPOTIFY_CLIENT_SECRET"]

    uri = 'https://accounts.spotify.com/api/token'
    authorization = 'Basic ' + Base64.strict_encode64("#{client_id}:#{client_secret}")
    request_body = {
      grant_type: 'refresh_token',
      refresh_token: refresh_token
    }

    access_token_response = request_spotify_api('POST', uri, authorization, request_body)
  end

  def profile
    access_token = params[:access_token]

    uri = 'https://api.spotify.com/v1/me'
    authorization = 'Bearer ' + access_token

    request_spotify_api('GET', uri, authorization)
  end
end
