require 'rails_helper'

RSpec.describe "Home", type: :system do
  it "shows landing page with feature descriptions" do
    visit root_path
    expect(page).to have_content("Email alias creation")
    expect(page).to have_content("Increased security")
    expect(page).to have_content("Spam protection")
    expect(page).to have_content("Improved privacy")
    expect(page).to have_content("Supported email providers")
  end

  it "has sign-in link" do
    visit root_path
    expect(page).to have_link("Sign in")
  end

  it "navigates to sign-in page when clicking sign-in" do
    visit root_path
    click_link "Sign in"
    expect(page).to have_current_path(new_user_session_path)
  end
end
