require 'rails_helper'

RSpec.describe "ImportDetails", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/import_details/index"
      expect(response).to have_http_status(:redirect)
    end
  end
end
