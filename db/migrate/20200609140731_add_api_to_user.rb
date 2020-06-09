class AddAPIToUser < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE TYPE api_enum AS ENUM ('gandixmlrpc', 'gandiv5', 'glesys');
    SQL
    add_column :users, :api, :api_enum
  end

  def down
    remove_column :users, :api
    execute <<-SQL
      DROP TYPE api_enum;
    SQL
  end
end
