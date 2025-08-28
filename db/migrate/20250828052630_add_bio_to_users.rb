class AddBioToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :bio, :text, limit:500
  end
end
