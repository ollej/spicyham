require 'rails_helper'

RSpec.describe "Authentication", type: :system do
  it "shows home page for unauthenticated user" do
    visit root_path
    expect(page).to have_content("Email alias creation")
  end

  it "signed-in user sees emails index" do
    user = create(:user)
    sign_in user

    mock_api = double("Facade::API", list: [])
    allow(Facade::API).to receive(:create).and_return(mock_api)

    visit emails_path
    expect(page).to have_content("Email forwards")
  end

  it "signed-in user can log out" do
    user = create(:user)
    sign_in user

    mock_api = double("Facade::API", list: [])
    allow(Facade::API).to receive(:create).and_return(mock_api)

    visit emails_path
    within("nav") do
      click_link "Log Out"
    end

    expect(page).to have_current_path(root_path)
  end
end
