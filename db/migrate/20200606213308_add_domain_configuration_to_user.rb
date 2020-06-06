class AddDomainConfigurationToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :domain, :string
    add_column :users, :api_user, :string
    add_column :users, :api_key, :string
  end
end
