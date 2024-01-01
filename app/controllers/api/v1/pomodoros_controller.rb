class Api::V1::PomodorosController < ApplicationController
  def create
    user = User.find_or_create_by(spotify_id: params[:spotify_user_id])
    pomodoro = Pomodoro.new(pomodoro_params)
    pomodoro.user = user
    if pomodoro.save
      render json: { pomodoro: pomodoro }, status: :created
    else
      render json: { errors: pomodoro.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    spotify_user_id = request.headers["Pomodoro-Authorization"]
    user = User.find_by(spotify_id: spotify_user_id)
    if user
      pomodoros = user.pomodoros
      render json: { pomodoros: pomodoros }, status: :ok
    else
      render json: { errors: ["Couldn't find User"] }, status: :unprocessable_entity
    end
  end

  def show
    pomodoro = Pomodoro.find_by(id: params[:id])
    if pomodoro
      render json: { pomodoro: pomodoro }, status: :ok
    else
      render json: { errors: ["Couldn't find Pomodoro"] }, status: :unprocessable_entity
    end
  end

  private
  def pomodoro_params
    params.require(:pomodoro).permit(:name, :work_time_playlist_id, :break_time_playlist_id, :work_time, :break_time, :term_count, :long_break_time)
  end
end
