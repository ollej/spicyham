require 'rails_helper'

RSpec.describe "Home", type: :system do
  context "unauthenticated" do
    it "shows hero section with feature descriptions" do
      visit home_path
      expect(page).to have_content("Email alias creation")
      expect(page).to have_content("Increased security")
      expect(page).to have_content("Spam protection")
      expect(page).to have_content("Improved privacy")
    end

    it "shows provider logo cloud" do
      visit home_path
      expect(page).to have_content(/works with/i)
      expect(page).to have_css("img[alt='Migadu']")
      expect(page).to have_css("img[alt='Gandi']")
      expect(page).to have_css("img[alt='Glesys']")
    end

    it "shows Sign in with Google button in hero" do
      visit home_path
      expect(page).to have_button("Sign in with Google")
    end

    it "shows CTA section with Sign in with Google button" do
      visit home_path
      expect(page).to have_content("Ready to protect your email?")
      expect(page).to have_button("Sign in with Google")
    end

    it "has OAuth buttons as real form POSTs with Turbo disabled" do
      visit home_path
      forms = all("form[action*='google_oauth2']")
      forms.each do |form|
        expect(form['method']).to eq('post')
        expect(form['data-turbo']).to eq('false')
      end
    end
  end

  context "authenticated" do
    before do
      sign_in create(:user)
      allow(Facade::API).to receive(:create).and_return(double("Facade::API", list: []))
    end

    it "shows Go to Emails CTA in hero" do
      visit home_path
      click_link "Go to Emails"
      expect(page).to have_content("Email forwards")
    end

    it "does not show the unauthenticated CTA section" do
      visit home_path
      expect(page).not_to have_content("Ready to protect your email?")
    end
  end

  it "has OAuth sign-in button as a real form POST with Turbo disabled" do
    visit new_user_session_path
    form = find("form[action*='google_oauth2']")
    expect(form['method']).to eq('post')
    expect(form['action']).to include('/users/auth/google_oauth2')
    expect(form['data-turbo']).to eq('false')
  end
end
