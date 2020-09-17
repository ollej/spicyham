class AddAliasTemplateToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :alias_template, :string, default: "{DOMAIN}"
  end
end
