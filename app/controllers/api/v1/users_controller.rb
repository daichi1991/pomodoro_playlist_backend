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

      auth_options = {
        url: 'https://accounts.spotify.com/api/token',
        body: {
          code: code,
          redirect_uri: redirect_uri,
          grant_type: 'authorization_code'
        },
        headers: {
          Authorization: 'Basic ' + Base64.strict_encode64("#{client_id}:#{client_secret}")
        },
        json: true
      }

      uri = URI.parse(auth_options[:url])
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.path)
      request.set_form_data(auth_options[:body])
      request['Authorization'] = auth_options[:headers][:Authorization]

      response = http.request(request)
      response_body = JSON.parse(response.body)
      render json: { response_body: response_body }
    end
  end

  def refresh_token
    refresh_token = params[:refresh_token]
    auth_options = {
      uri: 'https://accounts.spotify.com/api/token',
      body: {
        grant_type: 'refresh_token',
        refresh_token: refresh_token
      },
      headers: {
        Authorization: 'Basic ' + Base64.strict_encode64("#{client_id}:#{client_secret}")
      },
      json: true
    }

    uri = URI.parse(auth_options[:uri])
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path)
    request.set_form_data(auth_options[:body])
    request['Authorization'] = auth_options[:headers][:Authorization]

    response = http.request(request)
    response_body = JSON.parse(response.body)
    render json: { response_body: response_body }
  end
end
