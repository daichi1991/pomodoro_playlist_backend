require 'rails_helper'

RSpec.describe "Api::V1::Pomodoros", type: :request do
  let(:user) { FactoryBot.create(:user) }
  describe "GET /index" do
    before do
      FactoryBot.create_list(:pomodoro, 10, user_id: user.id)
    end
    it "returns http success" do
      get "/api/v1/pomodoros?spotify_id=#{user.spotify_id}"
      expect(response).to have_http_status(:success)
    end
    it "returns a list of pomodoros" do
      get "/api/v1/pomodoros?spotify_id=#{user.spotify_id}"
      expect(JSON.parse(response.body)["pomodoros"].count).to eq(10)
      
    end
    it "returns correct user.id" do
      get "/api/v1/pomodoros?spotify_id=#{user.spotify_id}"
      expect(JSON.parse(response.body)["pomodoros"][0]["user_id"]).to eq(user.id)
    end
    it "returns a list of pomodoros with the correct attributes" do
      get "/api/v1/pomodoros?spotify_id=#{user.spotify_id}"
      expect(JSON.parse(response.body)["pomodoros"][0].keys).to eq(["id", "user_id", "name", "work_time_playlist_id", "break_time_playlist_id", "work_time", "break_time", "term_count", "long_break_time", "created_at", "updated_at"])
    end
    it "returns blank array if user has no pomodoros" do
      user2 = FactoryBot.create(:user)
      get "/api/v1/pomodoros?spotify_id=#{user2.spotify_id}"
      expect(JSON.parse(response.body)["pomodoros"]).to eq([])
    end
    it "returns error if user does not exist" do
      get "/api/v1/pomodoros?spotify_id=123"
      expect(JSON.parse(response.body)["errors"]).to eq(["Couldn't find User"])
    end
  end
end
