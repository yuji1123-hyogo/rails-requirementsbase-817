class User < ApplicationRecord
  has_many :favorite_books, through: :likes, source: :book
  has_many :likes, dependent: :destroy

  has_secure_password
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true
end
