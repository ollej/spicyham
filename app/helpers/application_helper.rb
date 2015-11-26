module ApplicationHelper
  def icon_button(label = "", icon = nil)
    btn = ""
    btn += glyph(icon) if icon
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
end
