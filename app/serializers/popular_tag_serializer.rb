class PopularTagSerializer < ActiveModel::Serializer
  attributes :id, :name, :color, :color_code, :usage_count, :created_at

  def color_code
    object.color_code
  end

  def usage_count
    object.comments.count
  end
end
