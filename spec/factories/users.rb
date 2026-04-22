FactoryBot.define do
  factory :user do
    email { 'user@example.com' }
    password { 'password123' }
    domain { 'example.com' }
    api_key { 'test-key' }
    api_user { 'testuser' }
    api { 'Gandi v5' }
    default_forward { 'fwd@example.com' }
    alias_template { '{DOMAIN}' }
    provider { 'google_oauth2' }
    uid { '12345' }

    trait :admin do
      email { 'admin@example.com' }
      admin { true }
      uid { '67890' }
    end

    trait :no_api do
      api_key { nil }
      api_user { nil }
      api { nil }
    end
  end
end
