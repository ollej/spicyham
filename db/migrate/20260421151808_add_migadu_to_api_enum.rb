class AddMigaduToAPIEnum < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    execute "ALTER TYPE api_enum ADD VALUE 'migadu';"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
