module ApplicationHelper
  def icon_button(label = "", icon = nil)
    btn = ""
    btn += glyph(icon.to_sym) if icon
    btn += "<span class='hidden-xs'> #{label}</span>" unless label.blank?
    btn.html_safe
  end

  def format_date(date)
    if date.present?
      date.to_time.to_formatted_s(:db)
    else
      ''
    end
  end
end
