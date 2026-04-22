require 'rails_helper'

RSpec.describe "Zone", type: :system do
  let(:admin) { create(:user, :admin) }
  let(:mock_gandi_api) { double("Gandi::API", call: []) }
  let(:mock_zone) { double("Gandi::Zone", list: [], add: true, delete: true, save: true) }

  before do
    sign_in admin
    allow(Gandi::API).to receive(:new).and_return(mock_gandi_api)
    allow(Gandi::Zone).to receive(:new).and_return(mock_zone)
  end

  it "opens dropdown form when New record button is clicked" do
    records = [{ 'name' => 'test', 'type' => 'A', 'value' => '1.2.3.4', 'ttl' => 10800, 'id' => 1 }]
    allow(mock_zone).to receive(:list).and_return(records)

    visit "/zone/123"
    dropdown_menu = find("[data-dropdown-target='menu']", visible: :all)
    expect(dropdown_menu[:class]).to include("hidden")

    find("[data-action='click->dropdown#toggle']").click
    expect(dropdown_menu[:class]).not_to include("hidden")
    expect(page).to have_field("name")
    expect(page).to have_button("Add record")
  end

  it "closes dropdown when clicking outside" do
    records = [{ 'name' => 'test', 'type' => 'A', 'value' => '1.2.3.4', 'ttl' => 10800, 'id' => 1 }]
    allow(mock_zone).to receive(:list).and_return(records)

    visit "/zone/123"
    find("[data-action='click->dropdown#toggle']").click
    dropdown_menu = find("[data-dropdown-target='menu']")
    expect(dropdown_menu[:class]).not_to include("hidden")

    find("h1").click
    expect(dropdown_menu[:class]).to include("hidden")
  end
end
