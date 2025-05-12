# spec/features/signup_spec.rb
require 'rails_helper'

RSpec.feature "Merchant Signup", type: :feature do
  it "with valid credentials" do
    visit sign_up_path
    fill_in 'Slug', with: 'new-merchant'
    fill_in 'Password', with: 'PASSWORD'
    fill_in 'Password confirmation', with: 'PASSWORD'
    click_button 'Sign Up'

    aggregate_failures do
      expect(page).to have_content(/Welcome.*new-merchant/)
      expect(page).to have_content "Signed up successfully"
    end
  end

  it "with invalid credentials" do
    visit sign_up_path
    fill_in 'Slug', with: ''
    fill_in 'Password', with: 'PASSWORD'
    fill_in 'Password confirmation', with: 'DIFFERENT_PASSWORD'
    click_button 'Sign Up'

    aggregate_failures do
      expect(page).to have_content "Slug can't be blank"
      expect(page).to have_content "Password confirmation doesn't match Password"
    end
  end
end