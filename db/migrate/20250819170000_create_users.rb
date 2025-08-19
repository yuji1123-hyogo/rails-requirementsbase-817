class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name, null:false, limit:50
      t.string :email, null: false
      t.string :password, null:false
      t.timestamps
    end
    add_index :users, :name
    add_index :users, :email, unique:true
  end
end
