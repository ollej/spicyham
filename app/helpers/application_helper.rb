module ApplicationHelper
  def icon_button(label = "", icon = nil)
    btn = ""
    btn += glyph(icon.to_sym) if icon
    btn += "<span class='hidden-phone'> #{label}</span>" unless label.blank?
    btn.html_safe
  end

  def format_date(date)
    if date.present?
      date.to_formatted_s(:db)
    else
      ''
    end
  end

  # Copied from twitter-bootstrap-rails with fix for flash keys as strings change in Rails 4.1
  ALERT_TYPES = [:error, :info, :success, :warning]
  def bootstrap_flash_rails41
    flash_messages = []
    flash.each do |stype, message|
      # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
      next if message.blank?
      type = stype.to_sym

      type = :success if type == :notice
      type = :error   if type == :alert
      next unless ALERT_TYPES.include?(type)

      Array(message).each do |msg|
        text = content_tag(:div,
                           content_tag(:button, raw("&times;"), :class => "close", "data-dismiss" => "alert") +
                           msg.html_safe, :class => "alert fade in alert-#{type}")
        flash_messages << text if msg
      end
    end
    flash_messages.join("\n").html_safe
  end
end
