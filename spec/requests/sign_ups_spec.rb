require 'rails_helper'

RSpec.describe "SignUps", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/sign_ups/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/sign_ups/create"
      expect(response).to have_http_status(:success)
    end
  end
end
