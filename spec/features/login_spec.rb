# spec/features/login_spec.rb
require 'rails_helper'

RSpec.feature "Merchant Login", type: :feature do
  it "with valid credentials" do
    merchant = create(:merchant, password: 'PASSWORD')

    visit sessions_new_path
    fill_in 'Slug', with: merchant.slug
    fill_in 'Password', with: 'PASSWORD'
    click_button 'Sign In'

    aggregate_failures do
      expect(page).to have_content /Welcome.*#{merchant.slug}/
      expect(page).to have_content "Signed in successfully"
    end
  end

  it "with invalid credentials" do
    merchant = create(:merchant, password: 'PASSWORD')

    visit sessions_new_path
    fill_in 'Slug', with: merchant.slug
    fill_in 'Password', with: 'BAD PASSWORD'
    click_button 'Sign In'

    expect(page).to have_content "Invalid email or password"
  end

  context "as an admin merchant" do
    it "sees the Admin badge in the navbar" do
      merchant = create(:merchant, password: 'PASSWORD', role: "admin")

      visit sessions_new_path
      fill_in 'Slug', with: merchant.slug
      fill_in 'Password', with: 'PASSWORD'
      click_button 'Sign In'

      aggregate_failures do
        expect(page).to have_content "admin user"
        expect(page).not_to have_content "regular user"
      end
    end
  end

  context "as a regular merchant" do
    it "does not see the Admin badge" do
      merchant = create(:merchant, password: 'PASSWORD')

      visit sessions_new_path
      fill_in 'Slug', with: merchant.slug
      fill_in 'Password', with: 'PASSWORD'
      click_button 'Sign In'

      aggregate_failures do
        expect(page).not_to have_content "admin user"
        expect(page).to have_content "regular user"
      end
    end
  end
end
