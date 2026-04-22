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
    expect(page).to have_button("Delete")
  end

  it "opens confirm dialog showing email and destinations when clicking delete" do
    forwarding = Facade::Forwarding.new(
      source: 'testalias',
      domain: 'example.com',
      destinations: ['fwd@example.com']
    )
    allow(mock_api).to receive(:list).and_return([forwarding])

    visit emails_path
    click_button "Delete"

    expect(page).to have_content("Delete email alias")
    expect(page).to have_content("testalias@example.com")
    expect(page).to have_content("fwd@example.com")
  end

  it "removes email and shows flash after confirming delete" do
    forwarding = Facade::Forwarding.new(
      source: 'testalias',
      domain: 'example.com',
      destinations: ['fwd@example.com']
    )
    allow(mock_api).to receive(:list).and_return([forwarding], [])
    allow(mock_api).to receive(:delete)

    visit emails_path
    click_button "Delete"
    within("dialog") do
      click_button "Delete"
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
    click_button "Delete"
    within("dialog") do
      click_button "Delete"
    end

    expect(page).to have_content("Couldn't remove email forwarding")
  end

  it "dismisses flash alert when close button is clicked" do
    allow(mock_api).to receive(:list).and_return([], [])
    allow(mock_api).to receive(:delete)

    forwarding = Facade::Forwarding.new(
      source: 'testalias', domain: 'example.com', destinations: ['fwd@example.com']
    )
    allow(mock_api).to receive(:list).and_return([forwarding], [])
    allow(mock_api).to receive(:delete)

    visit emails_path
    click_button "Delete"
    within("dialog") do
      click_button "Delete"
    end

    expect(page).to have_content("Email forwarding removed")
    find("[data-action='click->alert#dismiss']").click
    expect(page).not_to have_content("Email forwarding removed")
  end

  it "shows combobox dropdown when typing in destination field" do
    forwarding = Facade::Forwarding.new(
      source: 'existing', domain: 'example.com', destinations: ['alice@example.com']
    )
    allow(mock_api).to receive(:list).and_return([forwarding])

    visit emails_path
    combobox_input = find("[data-combobox-target='input']")
    combobox_input.click

    expect(page).to have_css("[data-combobox-target='list']:not(.hidden)")
  end

  it "selects destination from combobox dropdown" do
    forwarding = Facade::Forwarding.new(
      source: 'existing', domain: 'example.com', destinations: ['alice@example.com']
    )
    allow(mock_api).to receive(:list).and_return([forwarding])
    allow(mock_api).to receive(:create)

    visit emails_path
    combobox_input = find("[data-combobox-target='input']")
    combobox_input.click
    find("[data-combobox-target='option']", text: "alice@example.com").click

    expect(combobox_input.value).to eq("alice@example.com")
    expect(find("[data-combobox-target='hidden']", visible: false).value).to eq("alice@example.com")
  end

  it "autoselects generated alias when email param is provided" do
    allow(mock_api).to receive(:list).and_return([])

    visit emails_path(email: "https://www.shop.example.com/page")
    address = find("#address")

    expect(address.value).not_to be_empty
    selection_length = page.evaluate_script("document.getElementById('address').selectionEnd - document.getElementById('address').selectionStart")
    expect(selection_length).to eq(address.value.length)
  end

  context "without API credentials" do
    let(:user) { create(:user, :no_api) }

    it "shows warning and hides the form" do
      visit emails_path
      expect(page).to have_content("API not configured")
      expect(page).to have_link("Go to Profile settings")
      expect(page).not_to have_button("Create")
      expect(page).not_to have_css("table")
    end
  end
end
