class TagSerializer < ActiveModel::Serializer
  attributes :id, :name, :color, :color_code, :created_at

  def color_code
    object.color_code
  end
end
