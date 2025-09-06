class CreateTags < ActiveRecord::Migration[7.1]
  def change
    create_table :tags do |t|
      t.string :name, null: false, limit: 20
      t.string :color, default: 0, null: false
      t.timestamps
    end

    add_index :tags, :name, unique: true
    add_index :tags, :color
  end
end
