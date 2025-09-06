# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# タグデータの作成
puts "Creating tags..."

tag_data = [
  { name: "初心者向け", color: :green },
  { name: "わかりやすい", color: :blue },
  { name: "実践的", color: :purple },
  { name: "感動した", color: :red },
  { name: "おすすめ", color: :yellow },
  { name: "専門的", color: :indigo },
  { name: "読みやすい", color: :pink },
  { name: "役に立つ", color: :green },
  { name: "面白い", color: :blue },
  { name: "難しい", color: :gray },
  { name: "網羅的", color: :purple },
  { name: "最新情報", color: :red },
  { name: "基礎知識", color: :yellow },
  { name: "上級者向け", color: :indigo },
  { name: "理論的", color: :gray }
]

tag_data.each do |data|
  tag = Tag.find_or_create_by(name: data[:name]) do |t|
    t.color = data[:color]
  end
  puts "✓ Created tag: #{tag.name} (#{tag.color})"
end

puts "Tags created: #{Tag.count}"