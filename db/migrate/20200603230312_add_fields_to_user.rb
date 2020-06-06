class AddFieldsToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :admin, :boolean, default: false
    add_column :users, :default_forward, :string, default: ""
  end
end
