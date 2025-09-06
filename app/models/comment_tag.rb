class CommentTag < ApplicationRecord
  belongs_to :comment
  belongs_to :tag

  validates :comment_id, uniqueness: { scope: :tag_id, message: 'このタグはすでに追加されています'}
end