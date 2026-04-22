# Secret key base is set via the SECRET_KEY_BASE or SECRET_TOKEN environment variable.
# In production, ensure this is set to a long random value.
# Generate one with: bin/rails secret
Rails.application.config.secret_key_base = ENV["SECRET_KEY_BASE"] || ENV["SECRET_TOKEN"]
