module ApplicationHelper
  def icon_button(label = "", icon = nil, icon_options = {})
    btn = ""
    btn += icon(icon.to_sym, icon_options) if icon
    btn += "<span class='hidden sm:inline'> #{label}</span>" unless label.blank?
    btn.html_safe
  end

  def icon(name, options = {})
    lucide_icon(name, class: "inline-block", size: options.fetch(:height, 24))
  end

  def format_date(date)
    if date.present?
      date.to_time.to_formatted_s(:db)
    else
      ''
    end
  end

  def bookmarklet
    @bookmarklet ||= "javascript:#{uri_encode(minify_js_file("public/bookmarklet.js"))}".html_safe
  end

  def uri_encode(data)
    ERB::Util.url_encode(data)
  end

  def minify_js_file(file)
    File.read(file).gsub(/\s+/, ' ').strip
  end

  def menu_item(name=nil, path="#", *args, &block)
    path = name || path if block_given?
    options = args.extract_options!
    active_class = is_active?(path, options) ? "font-semibold" : ""
    if block_given?
      link_to path, options.merge(class: "#{options[:class]} #{active_class}".strip), &block
    else
      link_to name, path, options.merge(class: "#{options[:class]} #{active_class}".strip), &block
    end
  end

  def is_active?(path, options = {})
    state = uri_state(path, options)
    state.in?([:active, :chosen]) || state === true
  end

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

  ALERT_STYLES = {
    success: "bg-green-900 text-green-200 border-green-700",
    info: "bg-purple-900 text-purple-200 border-purple-700",
    warning: "bg-yellow-900 text-yellow-200 border-yellow-700",
    danger: "bg-red-900 text-red-200 border-red-700"
  }.freeze

  def flash_messages
    messages = []
    flash.each do |type, message|
      next if message.blank?

      type = type.to_sym
      type = :success if type == :notice
      type = :danger  if type == :alert
      type = :danger  if type == :error
      next unless ALERT_TYPES.include?(type)

      style = ALERT_STYLES[type]

      Array(message).each do |msg|
        next unless msg
        messages << content_tag(:div, role: "alert",
          data: { controller: "alert" },
          class: "border rounded p-4 mb-4 flex justify-between items-start #{style}") do
          content_tag(:span, msg) +
          content_tag(:button, raw("&times;"), type: "button",
            class: "ml-4 text-lg leading-none opacity-50 hover:opacity-100",
            data: { action: "click->alert#dismiss" }, "aria-label" => "Close")
        end
      end
    end
    messages.join("\n").html_safe
  end
end
