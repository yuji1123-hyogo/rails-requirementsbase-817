class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :created_at, :avatar_url

  has_many :favorite_books, each_serialize: BookSerializer

  def avatar_url
    object.avatar_url
  end
end
