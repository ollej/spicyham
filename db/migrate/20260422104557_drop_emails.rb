class DropEmails < ActiveRecord::Migration[8.1]
  def change
    drop_table :emails do |t|
      t.string :address, limit: 255
      t.text :destinations
      t.timestamps null: true
    end
  end
end
