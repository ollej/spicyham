require 'rails_helper'

RSpec.describe Gandi::Email do
  let(:server) { double("Gandi::API") }
  let(:email) { described_class.new(server, 'example.com') }

  describe '#list' do
    it "calls server with domain.forward.list" do
      expect(server).to receive(:call).with('domain.forward.list', 'example.com', {}).and_return([])
      email.list
    end

    it "passes options to the server call" do
      opts = { items_per_page: 500 }
      expect(server).to receive(:call).with('domain.forward.list', 'example.com', opts).and_return([])
      email.list(opts)
    end
  end

  describe '#create' do
    it "calls server with domain.forward.create" do
      opts = { 'destinations' => ['fwd@example.com'] }
      expect(server).to receive(:call).with('domain.forward.create', 'example.com', 'alias', opts)
      email.create('alias', opts)
    end
  end

  describe '#delete' do
    it "calls server with domain.forward.delete" do
      expect(server).to receive(:call).with('domain.forward.delete', 'example.com', 'alias')
      email.delete('alias')
    end
  end

  describe '#update' do
    it "calls server with domain.forward.update" do
      opts = { 'destinations' => ['new@example.com'] }
      expect(server).to receive(:call).with('domain.forward.update', 'example.com', 'alias', opts)
      email.update('alias', opts)
    end
  end

  describe '#update_matching' do
    it "updates forwards matching old destination" do
      forwards = [
        { "source" => "a", "destinations" => ["old@example.com"] },
        { "source" => "b", "destinations" => ["other@example.com"] },
        { "source" => "c", "destinations" => ["old@example.com"] }
      ]
      allow(server).to receive(:call).with('domain.forward.list', 'example.com', { items_per_page: 500 }).and_return(forwards)
      allow(server).to receive(:call).with('domain.forward.update', anything, anything, anything)
      expect(server).to receive(:call).with('domain.forward.update', 'example.com', 'a', { 'destinations' => ['new@example.com'] })
      expect(server).to receive(:call).with('domain.forward.update', 'example.com', 'c', { 'destinations' => ['new@example.com'] })

      email.update_matching('old@example.com', 'new@example.com')
    end
  end
end
