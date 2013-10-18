class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :address
      t.text :destinations

      t.timestamps
    end
  end
end
