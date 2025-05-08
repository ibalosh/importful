require 'rails_helper'

RSpec.describe "Affiliates", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/affiliates"
      expect(response).to have_http_status(:redirect)
    end
  end
end
