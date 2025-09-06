class ChangeColorTypeToIntegerInTags < ActiveRecord::Migration[7.1]
  def change
    change_column :tags, :color, :integer, null: false, default: 0
  end
end
