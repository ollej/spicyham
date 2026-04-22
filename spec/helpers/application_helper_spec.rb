require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  before do
    allow(helper).to receive(:octicon).and_return('<svg class="octicon"></svg>'.html_safe)
  end

  describe '#icon_button' do
    it "returns label in a responsive span with icon" do
      result = helper.icon_button("Delete", :x)
      expect(result).to include('<svg class="octicon">')
      expect(result).to include("<span class='d-none d-sm-inline'> Delete</span>")
    end

    it "returns only icon when label is blank" do
      result = helper.icon_button("", :x)
      expect(result).to include('<svg class="octicon">')
      expect(result).not_to include('<span')
    end

    it "returns html_safe string" do
      expect(helper.icon_button("Test", :check)).to be_html_safe
    end
  end

  describe '#icon' do
    it "delegates to octicon with default height 24" do
      expect(helper).to receive(:octicon).with(:check, { height: 24 })
      helper.icon(:check)
    end

    it "allows overriding height" do
      expect(helper).to receive(:octicon).with(:check, { height: 16 })
      helper.icon(:check, height: 16)
    end
  end

  describe '#format_date' do
    it "returns formatted date string for present date" do
      date = Time.new(2025, 3, 15, 10, 30, 0)
      expect(helper.format_date(date)).to eq('2025-03-15 10:30:00')
    end

    it "returns empty string for nil" do
      expect(helper.format_date(nil)).to eq('')
    end

    it "returns empty string for blank" do
      expect(helper.format_date('')).to eq('')
    end
  end

  describe '#uri_encode' do
    it "URL-encodes the input string" do
      expect(helper.uri_encode('hello world')).to eq('hello%20world')
    end
  end

  describe '#minify_js_file' do
    it "reads and minifies whitespace from a JS file" do
      result = helper.minify_js_file('public/bookmarklet.js')
      expect(result).to be_a(String)
      expect(result).not_to include("\n")
    end
  end

  describe '#bookmarklet' do
    it "returns javascript: URI with encoded uglified JS" do
      result = helper.bookmarklet
      expect(result).to start_with('javascript:')
      expect(result).to be_html_safe
    end
  end

  describe '#menu_item' do
    before do
      allow(helper.request).to receive(:host_with_port).and_return('www.example.com')
      allow(helper.request).to receive(:url).and_return('http://www.example.com/emails')
      allow(helper.request).to receive(:path).and_return('/emails')
    end

    it "renders li with nav-item class containing a link" do
      result = helper.menu_item('Emails', '/emails')
      expect(result).to include('nav-item')
      expect(result).to include('href="/emails"')
      expect(result).to include('Emails')
    end

    it "adds active class when path matches current request" do
      result = helper.menu_item('Emails', '/emails')
      expect(result).to include('nav-item active')
    end
  end

  describe '#is_active?' do
    before do
      allow(helper.request).to receive(:host_with_port).and_return('www.example.com')
      allow(helper.request).to receive(:url).and_return('http://www.example.com/emails')
      allow(helper.request).to receive(:path).and_return('/emails')
    end

    it "returns 'active' when path matches current request" do
      expect(helper.is_active?('/emails')).to eq('active')
    end

    it "returns nil when path does not match" do
      expect(helper.is_active?('/domain')).to be_nil
    end
  end

  describe '#uri_state' do
    before do
      allow(helper.request).to receive(:host_with_port).and_return('www.example.com')
      allow(helper.request).to receive(:url).and_return('http://www.example.com/emails')
      allow(helper.request).to receive(:path).and_return('/emails')
    end

    it "returns :active when URI matches current request path" do
      expect(helper.uri_state('/emails')).to eq(:active)
    end

    it "returns :chosen when request path starts with URI" do
      allow(helper.request).to receive(:path).and_return('/emails/new')
      expect(helper.uri_state('/emails')).to eq(:chosen)
    end

    it "returns :inactive when URI does not match" do
      expect(helper.uri_state('/domain')).to eq(:inactive)
    end

    it "returns :inactive when options include :method" do
      expect(helper.uri_state('/emails', method: :delete)).to eq(:inactive)
    end

    it "returns custom status when options[:status] is set" do
      expect(helper.uri_state('/emails', status: :custom)).to eq(:custom)
    end
  end

  describe '#bootstrap_flash_close_button' do
    it "returns button with close class and data-dismiss" do
      result = helper.bootstrap_flash_close_button
      expect(result).to include('class="close"')
      expect(result).to include('data-dismiss="alert"')
      expect(result).to include('<button')
    end
  end

  describe '#bootstrap_flash' do
    it "renders alert div for notice flash mapped to success" do
      flash[:notice] = "It worked!"
      result = helper.bootstrap_flash
      expect(result).to include('alert-success')
      expect(result).to include('It worked!')
    end

    it "renders alert div for error flash mapped to danger" do
      flash[:error] = "Something broke"
      result = helper.bootstrap_flash
      expect(result).to include('alert-danger')
      expect(result).to include('Something broke')
    end

    it "skips blank messages" do
      flash[:notice] = ""
      result = helper.bootstrap_flash
      expect(result).to eq('')
    end
  end
end
