class User < ApplicationRecord
  has_many :likes, dependent: :destroy
  has_many :favorite_books, through: :likes, source: :book
  has_many :comments, dependent: :destroy
  has_many :commented_books, through: :comments, source: :book
  has_many :notifications, foreign_key: 'recipient_id', dependent: :destroy
  has_one_attached :avatar

  has_secure_password
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :bio, length: { maximum: 500 }
  validates :password, presence: true, on: :create
  validates :password, length: { minimum: 8 },
                       format: {
                         with: /\A(?=.*[a-zA-Z])(?=.*\d).+\z/,
                         message: 'must include both letters and numbers'
                       }, allow_nil: true
  validate :validate_avatar_type, if: -> { avatar.attached? }
  validate :validate_avatar_size, if: -> { avatar.attached? }

  before_save { self.email = email.downcase }

  def validate_avatar_type
    allowed_types = ['image/jpeg', 'image/jpg', 'image/png']

    return if avatar.content_type.in?(allowed_types)

    errors.add(
      :avatar,
      'JPEG,JPG,PNGのいずれかの形式でアップロードしてください'
    )
  end

  def validate_avatar_size
    max_size = 2.megabytes
    return unless avatar.blob.byte_size > max_size

    errors.add(
      :avatar,
      'ファイルサイズが大きすぎます。2MB以下のファイルを選択してください'
    )
  end

  def avatar_url
    return nil unless avatar.attached?

    Rails.application.routes.url_helpers.url_for(avatar)
  rescue StandardError => e
    Rails.logger.error "Avatar URL generation failed: #{e.message}"
    nil
  end

  def unread_notifications_count
    notifications.unread.count
  end
end
