require 'rails_helper'

RSpec.describe "Emails", type: :system do
  let(:user) { create(:user) }
  let(:mock_api) { double("Facade::API") }

  before do
    sign_in user
    allow(Facade::API).to receive(:create).and_return(mock_api)
  end

  it "renders index with form and table showing emails from API" do
    forwarding = Facade::Forwarding.new(
      source: 'hello',
      domain: 'example.com',
      destinations: ['fwd@example.com']
    )
    allow(mock_api).to receive(:list).and_return([forwarding])

    visit emails_path
    expect(page).to have_content("Email forwards")
    expect(page).to have_field("address")
    within("table") do
      expect(page).to have_content("hello")
      expect(page).to have_content("fwd@example.com")
    end
  end

  it "has address field, destinations combobox, and Create button" do
    allow(mock_api).to receive(:list).and_return([])

    visit emails_path
    expect(page).to have_field("address")
    expect(page).to have_css("[data-controller='combobox']")
    expect(page).to have_button("Create")
  end

  it "creates an email by filling address and selecting destination" do
    forwarding = Facade::Forwarding.new(
      source: 'existing',
      domain: 'example.com',
      destinations: ['fwd@example.com']
    )
    allow(mock_api).to receive(:list).and_return([forwarding])
    allow(mock_api).to receive(:create)

    visit emails_path
    fill_in "address", with: "newalias"
    # Set the hidden field value for the Stimulus combobox
    page.execute_script("document.querySelector('[data-combobox-target=\"hidden\"]').value = 'fwd@example.com'")
    click_button "Create"

    expect(page).to have_content("Email alias created")
    expect(page).to have_button("Copy")
    expect(page).to have_css(".copy-clipboard[data-clipboard-text='newalias@example.com']")
  end

  it "shows delete button for each email row" do
    forwarding = Facade::Forwarding.new(
      source: 'testalias',
      domain: 'example.com',
      destinations: ['fwd@example.com']
    )
    allow(mock_api).to receive(:list).and_return([forwarding])

    visit emails_path
    expect(page).to have_content("testalias")
    expect(page).to have_link("Delete")
  end

  it "removes email and shows flash after clicking delete" do
    forwarding = Facade::Forwarding.new(
      source: 'testalias',
      domain: 'example.com',
      destinations: ['fwd@example.com']
    )
    allow(mock_api).to receive(:list).and_return([forwarding], [])
    allow(mock_api).to receive(:delete)

    visit emails_path
    accept_confirm do
      click_link "Delete"
    end

    expect(page).to have_content("Email forwarding removed")
    within("table") do
      expect(page).not_to have_content("testalias")
    end
  end

  it "shows error flash when delete fails" do
    forwarding = Facade::Forwarding.new(
      source: 'testalias',
      domain: 'example.com',
      destinations: ['fwd@example.com']
    )
    allow(mock_api).to receive(:list).and_return([forwarding])
    allow(mock_api).to receive(:delete).and_raise(Facade::Error, "Not found")

    visit emails_path
    accept_confirm do
      click_link "Delete"
    end

    expect(page).to have_content("Couldn't remove email forwarding")
  end
end
