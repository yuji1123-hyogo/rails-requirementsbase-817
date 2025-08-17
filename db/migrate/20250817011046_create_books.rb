class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :books do |t|
      t.string :title, null: false, limit: 200
      t.string :author, null: false, limit: 100
      t.string :isbn, limit: 13
      t.text :description, limit: 1000
      t.integer :genre, null: false, default: 0
      t.date :published_date

      t.timestamps
    end

    add_index :books, :isbn, unique: true
    add_index :books, :author
    add_index :books, :published_date
  end
end
