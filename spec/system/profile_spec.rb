require 'rails_helper'

RSpec.describe "Profile", type: :system do
  let(:user) { create(:user) }

  before { sign_in user }

  it "renders edit form with all fields" do
    visit edit_user_registration_path
    expect(page).to have_content("Edit profile")
    expect(page).to have_field("user_email")
    expect(page).to have_field("user_default_forward")
    expect(page).to have_field("user_domain")
    expect(page).to have_select("user_api")
    expect(page).to have_field("user_api_user")
    expect(page).to have_field("user_api_key")
    expect(page).to have_field("user_alias_template")
  end

  it "has Test API button" do
    visit edit_user_registration_path
    expect(page).to have_content("Test API")
  end

  it "shows green checkmark when API test succeeds" do
    mock_api = double("Facade::API", list: [])
    allow(Facade::API).to receive(:create).and_return(mock_api)

    visit edit_user_registration_path
    click_link "Test API"

    expect(page).to have_css(".test-api-btn.border-green-600", wait: 5)
    expect(page).to have_css(".test-api-success:not(.hidden)")
  end

  it "shows red alert icon when API test fails" do
    allow(Facade::API).to receive(:create).and_raise(Facade::Error, "Auth failed")

    visit edit_user_registration_path
    click_link "Test API"

    expect(page).to have_css(".test-api-btn.border-red-600", wait: 5)
    expect(page).to have_css(".test-api-failed:not(.hidden)")
  end

  it "reveals confirmation input when Cancel my account is clicked" do
    visit edit_user_registration_path
    click_button "Cancel my account"

    expect(page).to have_content("Type DELETE to confirm")
    expect(page).to have_button("Confirm deletion", disabled: true)
  end

  it "keeps confirm button disabled until DELETE is typed" do
    visit edit_user_registration_path
    click_button "Cancel my account"

    fill_in placeholder: "DELETE", with: "DELE"
    expect(page).to have_button("Confirm deletion", disabled: true)

    fill_in placeholder: "DELETE", with: "DELETE"
    expect(page).to have_button("Confirm deletion", disabled: false)
  end

  it "deletes user account after typing DELETE and confirming" do
    visit edit_user_registration_path
    click_button "Cancel my account"
    fill_in placeholder: "DELETE", with: "DELETE"
    click_button "Confirm deletion"

    expect(page).to have_current_path(root_path)
    expect(User.find_by(id: user.id)).to be_nil
  end
end
