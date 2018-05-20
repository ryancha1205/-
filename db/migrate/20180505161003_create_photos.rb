class CreatePhotos < ActiveRecord::Migration[5.2]
  def change
    create_table :photos do |t|
      t.references :listing, foreign_key: true

      t.timestamps null: false
    end
  end
end
