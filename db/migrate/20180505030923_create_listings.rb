class CreateListings < ActiveRecord::Migration[5.2]
  def change
    create_table :listings do |t|
      t.string :car_type
      t.string :car_brand
      t.string :car_size
      t.string :car_years
      t.string :address
      t.string :listing_title
      t.text :listing_content
      t.integer :price_per_day
      t.boolean :active
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
