require 'rails_helper'

RSpec.describe "Navigation", type: :system do
  before do
    allow(Facade::API).to receive(:create).and_return(double("Facade::API", list: []))
  end

  context "as admin" do
    before { sign_in create(:user, :admin) }

    it "renders navbar with all menu links" do
      visit emails_path
      within("nav") do
        expect(page).to have_content("Spicyham")
        expect(page).to have_content("Emails")
        expect(page).to have_content("Zones")
        expect(page).to have_content("Domains")
        expect(page).to have_content("Web Redirs")
        expect(page).to have_content("Profile")
        expect(page).to have_content("Log Out")
      end
    end

    it "renders sidebar with bookmarklet link" do
      visit emails_path
      expect(page).to have_link("Spicyham bookmarklet")
    end
  end

  context "as regular user" do
    before { sign_in create(:user) }

    it "renders navbar with only Profile and Log Out" do
      visit emails_path
      within("nav") do
        expect(page).to have_content("Spicyham")
        expect(page).to have_content("Profile")
        expect(page).to have_content("Log Out")
        expect(page).not_to have_content("Zones")
        expect(page).not_to have_content("Domains")
        expect(page).not_to have_content("Web Redirs")
      end
    end
  end
end
