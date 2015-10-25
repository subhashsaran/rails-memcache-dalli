class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.decimal :price
      t.date :released_on
      t.integer :category_id

      t.timestamps
    end
    add_index :products, :category_id
  end
end
