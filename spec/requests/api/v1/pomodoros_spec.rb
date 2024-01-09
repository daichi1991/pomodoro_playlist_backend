require 'rails_helper'

RSpec.describe "Api::V1::Pomodoros", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let!(:pomodoros) { FactoryBot.create_list(:pomodoro, 10, user: user) }
  let(:request_headers) { { "Pomodoro-Authorization" => user.spotify_id } }
  describe "GET /index" do
    it "returns http success" do
      get "/api/v1/pomodoros", headers: request_headers
      expect(response).to have_http_status(:success)
    end
    it "returns a list of pomodoros" do
      get "/api/v1/pomodoros", headers: request_headers
      expect(JSON.parse(response.body)["pomodoros"].count).to eq(10)
      
    end
    it "returns correct user.id" do
      get "/api/v1/pomodoros", headers: request_headers
      expect(JSON.parse(response.body)["pomodoros"][0]["user_id"]).to eq(user.id)
    end
    it "returns a list of pomodoros with the correct attributes" do
      get "/api/v1/pomodoros", headers: request_headers
      expect(JSON.parse(response.body)["pomodoros"][0].keys).to eq(["id", "user_id", "name", "work_time_playlist_id", "break_time_playlist_id", "work_time", "break_time", "term_count", "long_break_time", "term_repeat_count", "created_at", "updated_at"])
    end
    it "returns blank array if user has no pomodoros" do
      user2 = FactoryBot.create(:user)
      get "/api/v1/pomodoros", headers: { "Pomodoro-Authorization" => user2.spotify_id }
      expect(JSON.parse(response.body)["pomodoros"]).to eq([])
    end
    it "returns error if user does not exist" do
      get "/api/v1/pomodoros", headers: { "Pomodoro-Authorization" => user.spotify_id + "123"}
      expect(JSON.parse(response.body)["errors"]).to eq(["Couldn't find User"])
    end
  end
  describe "POST /create" do
    context "when existing user" do
      it "returns created status" do
        post "/api/v1/pomodoros", params: { spotify_user_id: user.spotify_id, pomodoro: { name: "Test Pomodoro", work_time_playlist_id: "123", break_time_playlist_id: "456", work_time: 25, break_time: 5, term_count: 4, long_break_time: 15, term_repeat_count: 3 } }
        expect(response).to have_http_status(:created)
      end
      it "creates a pomodoro" do
        expect {
          post "/api/v1/pomodoros", params: { spotify_user_id: user.spotify_id, pomodoro: { name: "Test Pomodoro", work_time_playlist_id: "123", break_time_playlist_id: "456", work_time: 25, break_time: 5, term_count: 4, long_break_time: 15, term_repeat_count: 3 } }
        }.to change(Pomodoro, :count).by(1)
      end
      it "returns the created pomodoro" do
        post "/api/v1/pomodoros", params: { spotify_user_id: user.spotify_id, pomodoro: { name: "Test Pomodoro", work_time_playlist_id: "123", break_time_playlist_id: "456", work_time: 25, break_time: 5, term_count: 4, long_break_time: 15, term_repeat_count: 3 } }
        expect(JSON.parse(response.body)["pomodoro"].keys).to eq(["id", "user_id", "name", "work_time_playlist_id", "break_time_playlist_id", "work_time", "break_time", "term_count", "long_break_time", "term_repeat_count", "created_at", "updated_at"])
      end
      it "returns error if pomodoro is invalid" do
        post "/api/v1/pomodoros", params: { spotify_user_id: user.spotify_id, pomodoro: { name: "Test Pomodoro", work_time_playlist_id: "123", break_time_playlist_id: "456", work_time: 25, break_time: 5, term_count: 4, long_break_time: -15, term_repeat_count: 3 } }
        expect(JSON.parse(response.body)["errors"]).to eq(["Long break time must be greater than 0"])
      end
    end
    context "when new user" do
      it "returns created status" do
        post "/api/v1/pomodoros", params: { spotify_user_id: "abc123", pomodoro: { name: "Test Pomodoro", work_time_playlist_id: "123", break_time_playlist_id: "456", work_time: 25, break_time: 5, term_count: 4, long_break_time: 15, term_repeat_count: 3 } }
        expect(response).to have_http_status(:created)
      end
      it "creates a pomodoro" do
        expect {
          post "/api/v1/pomodoros", params: { spotify_user_id: "abc123", pomodoro: { name: "Test Pomodoro", work_time_playlist_id: "123", break_time_playlist_id: "456", work_time: 25, break_time: 5, term_count: 4, long_break_time: 15, term_repeat_count: 3 } }
        }.to change(Pomodoro, :count).by(1)
      end
      it "returns the created pomodoro" do
        post "/api/v1/pomodoros", params: { spotify_user_id: "abc123", pomodoro: { name: "Test Pomodoro", work_time_playlist_id: "123", break_time_playlist_id: "456", work_time: 25, break_time: 5, term_count: 4, long_break_time: 15, term_repeat_count: 3 } }
        expect(JSON.parse(response.body)["pomodoro"].keys).to eq(["id", "user_id", "name", "work_time_playlist_id", "break_time_playlist_id", "work_time", "break_time", "term_count", "long_break_time", "term_repeat_count",  "created_at", "updated_at"])
      end
      it "returns error if pomodoro is invalid" do
        post "/api/v1/pomodoros", params: { spotify_user_id: "abc123", pomodoro: { name: "Test Pomodoro", work_time_playlist_id: "123", break_time_playlist_id: "456", work_time: 25, break_time: 5, term_count: 4, long_break_time: -15, term_repeat_count: 3 } }
        expect(JSON.parse(response.body)["errors"]).to eq(["Long break time must be greater than 0"])
      end
    end
  end
  describe "GET /show" do
    it "returns http success" do
      get "/api/v1/pomodoros/#{pomodoros[0].id}", headers: request_headers
      expect(response).to have_http_status(:success)
    end
    it "returns the correct pomodoro" do
      get "/api/v1/pomodoros/#{pomodoros[0].id}", headers: request_headers
      expect(JSON.parse(response.body)["pomodoro"].keys).to eq(["id", "user_id", "name", "work_time_playlist_id", "break_time_playlist_id", "work_time", "break_time", "term_count", "long_break_time", "term_repeat_count", "created_at", "updated_at"])
    end
    it "returns error if pomodoro does not exist" do
      get "/api/v1/pomodoros/123", headers: request_headers
      expect(JSON.parse(response.body)["errors"]).to eq(["Couldn't find Pomodoro"])
    end
  end
  describe "PUT /update" do
    it "returns http success" do
      put "/api/v1/pomodoros/#{pomodoros[0].id}", params: { pomodoro: { name: "Updated Pomodoro" } }, headers: request_headers
      expect(response).to have_http_status(:success)
    end
    it "updates the pomodoro" do
      expect {
        put "/api/v1/pomodoros/#{pomodoros[0].id}", params: { pomodoro: { name: "Updated Pomodoro" } }, headers: request_headers
      }.to change { pomodoros[0].reload.name }.from(pomodoros[0].name).to("Updated Pomodoro")
    end
    it "returns the updated pomodoro" do
      put "/api/v1/pomodoros/#{pomodoros[0].id}", params: { pomodoro: { name: "Updated Pomodoro" } }, headers: request_headers
      expect(JSON.parse(response.body)["pomodoro"].keys).to eq(["name", "work_time", "break_time", "term_count", "long_break_time", "term_repeat_count", "id", "user_id", "work_time_playlist_id", "break_time_playlist_id", "created_at", "updated_at"])
    end
    it "returns error if pomodoro does not exist" do
      put "/api/v1/pomodoros/123", params: { pomodoro: { name: "Updated Pomodoro" } }, headers: request_headers
      expect(JSON.parse(response.body)["errors"]).to eq(["Couldn't find Pomodoro"])
    end
    it "returns error if pomodoro is invalid" do
      put "/api/v1/pomodoros/#{pomodoros[0].id}", params: { pomodoro: { long_break_time: -15 } }, headers: request_headers
      expect(JSON.parse(response.body)["errors"]).to eq(["Long break time must be greater than 0"])
    end
  end
  describe "DELETE /destroy" do
    it "returns http success" do
      delete "/api/v1/pomodoros/#{pomodoros[0].id}", headers: request_headers
      expect(response).to have_http_status(:success)
    end
    it "deletes the pomodoro" do
      expect {
        delete "/api/v1/pomodoros/#{pomodoros[0].id}", headers: request_headers
      }.to change(Pomodoro, :count).by(-1)
    end
    it "returns the deleted pomodoro" do
      delete "/api/v1/pomodoros/#{pomodoros[0].id}", headers: request_headers
      expect(JSON.parse(response.body)["pomodoro"].keys).to eq(["id", "user_id", "name", "work_time_playlist_id", "break_time_playlist_id", "work_time", "break_time", "term_count", "long_break_time", "term_repeat_count", "created_at", "updated_at"])
    end
    it "returns error if pomodoro does not exist" do
      delete "/api/v1/pomodoros/xyz", headers: request_headers
      expect(JSON.parse(response.body)["errors"]).to eq(["Couldn't find Pomodoro"])
    end
  end
end
