module ApplicationHelper
  def icon_button(label = "", icon = nil, icon_options = {})
    btn = ""
    btn += icon(icon.to_sym, icon_options) if icon
    btn += "<span class='d-none d-sm-inline'> #{label}</span>" unless label.blank?
    btn.html_safe
  end

  def icon(icon, options = {})
    octicon(icon, { height: 24 }.merge(options))
  end

  def format_date(date)
    if date.present?
      date.to_time.to_formatted_s(:db)
    else
      ''
    end
  end

  def bookmarklet
    @bookmarklet ||= "javascript:#{uri_encode(uglify_js_file("public/bookmarklet.js"))}".html_safe
  end

  def uri_encode(data)
    ERB::Util.url_encode(data)
  end

  def uglify_js_file(file)
    uglify_js(File.read(file))
  end

  def uglify_js(js)
    Uglifier.new(
      compress: {
        reduce_vars: true,
        negate_iife: false,
        join_vars: true,
        collapse_vars: true
    }).compile(js)
  end

  # Methods from twitter-bootstrap-rails

  def menu_item(name=nil, path="#", *args, &block)
    path = name || path if block_given?
    options = args.extract_options!
    content_tag :li, :class => ['nav-item', is_active?(path, options)] do
      if block_given?
        link_to path, options, &block
      else
        link_to name, path, options, &block
      end
    end
  end

  def is_active?(path, options = {})
    state = uri_state(path, options)
    "active" if state.in?([:active, :chosen]) || state === true
  end

  # Returns current url or path state (useful for buttons).
  # Example:
  #   # Assume we'r currently at blog/categories/test
  #   uri_state('/blog/categories/test', {})               # :active
  #   uri_state('/blog/categories', {})                    # :chosen
  #   uri_state('/blog/categories/test', {method: delete}) # :inactive
  #   uri_state('/blog/categories/test/3', {})             # :inactive
  def uri_state(uri, options={})
    return options[:status] if options.key?(:status)

    root_url = request.host_with_port + '/'
    root = uri == '/' || uri == root_url

    request_uri = if uri.start_with?(root_url)
                    request.url
                  else
                    request.path
                  end

    if !options[:method].nil? || !options["data-method"].nil?
      :inactive
    elsif uri == request_uri || (options[:root] && (request_uri == '/') || (request_uri == root_url))
      :active
    else
      if request_uri.start_with?(uri) and not(root)
        :chosen
      else
        :inactive
      end
    end
  end

  ALERT_TYPES = [:success, :info, :warning, :danger] unless const_defined?(:ALERT_TYPES)

  def bootstrap_flash_close_button
    content_tag(:button, raw("&times;"), type: "button", class: "close", "data-dismiss" => "alert", "aria-label" => "Close")
  end

  def bootstrap_flash(options = {})
    flash_messages = []
    flash.each do |type, message|
      # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
      next if message.blank?

      type = type.to_sym
      type = :success if type == :notice
      type = :danger  if type == :alert
      type = :danger  if type == :error
      next unless ALERT_TYPES.include?(type)

      tag_class = options.extract!(:class)[:class]
      tag_options = {
        class: "alert fade show alert-dismissible alert-#{type} #{tag_class}",
        role: "alert"
      }.merge(options)

      Array(message).each do |msg|
        flash_messages << content_tag(:div, bootstrap_flash_close_button + msg, tag_options) if msg
      end
    end
    flash_messages.join("\n").html_safe
  end
end
