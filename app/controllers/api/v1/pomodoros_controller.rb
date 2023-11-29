class Api::V1::PomodorosController < ApplicationController
  def create
    user = User.find_or_create_by(spotify_id: params[:spotify_id])
    pomodoro = Pomodoro.new(pomodoro_params)
    pomodoro.user = user
    if pomodoro.save
      render json: { pomodoro: pomodoro }, status: :created
    else
      render json: { errors: pomodoro.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    user = User.find_by(spotify_id: params[:spotify_id])
    if user
      pomodoros = user.pomodoros
      render json: { pomodoros: pomodoros }, status: :ok
    else
      render json: { errors: ["Couldn't find User"] }, status: :unprocessable_entity
    end
  end
end
