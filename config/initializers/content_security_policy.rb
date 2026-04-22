Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data, "fonts.googleapis.com", "fonts.gstatic.com"
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    policy.script_src  :self, :https
    policy.style_src   :self, :https, :unsafe_inline, "fonts.googleapis.com"
    policy.connect_src :self, :https
  end

  # Report violations without enforcing the policy.
  config.content_security_policy_report_only = true
end
