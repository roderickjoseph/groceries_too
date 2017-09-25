class CreateItems < ActiveRecord::Migration[5.0]
  def change
    create_table :items do |t|
      t.string :name
      t.integer :list_id
      t.integer :user_id
      t.timestamps
    end
    add_index :items, :user_id
    add_index :items, :list_id
  end
end
