class User < ApplicationRecord
  has_many :favorite_books, through: :likes, source: :book
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :commented_books, through: :comments, source: :book

  has_secure_password
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, on: :create
  validates :password, length: { minimum: 8 },
                       format: {
                         with: /\A(?=.*[a-zA-Z])(?=.*\d).+\z/,
                         message: 'must include both letters and numbers'
                       }, allow_nil: true
  before_save { self.email = email.downcase }
end
