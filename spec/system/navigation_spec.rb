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

    it "toggles mobile menu when hamburger button is clicked" do
      visit emails_path

      # Make hamburger visible and strip desktop md:flex to test toggle in isolation
      page.execute_script <<~JS
        document.querySelector('[data-action="click->toggle\\\\#toggle"]').style.display = 'block';
        document.querySelector('[data-toggle-target="menu"]').classList.remove('md:flex');
      JS

      menu = find("[data-toggle-target='menu']", visible: :all)
      expect(menu[:class]).to include("hidden")

      find("[data-action='click->toggle#toggle']").click
      expect(menu[:class]).not_to include("hidden")

      find("[data-action='click->toggle#toggle']").click
      expect(menu[:class]).to include("hidden")
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
