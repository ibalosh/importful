require 'rails_helper'

RSpec.describe "Imports", type: :request do
  describe "GET /" do
    it "returns http success" do
      get "/imports"
      expect(response).to have_http_status(:redirect)
    end
  end
end
