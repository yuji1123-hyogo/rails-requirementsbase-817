class Book < ApplicationRecord
  validates :title, presence: true, length: { minimum:1, maximum: 200 }
  validates :author, presence: true, length: { minimum: 1, maximum: 100 }
  validates :isbn, uniqueness: true, allow_nil: true, length: { is: 13 }, numericality: { only_integer: true }
  validates :description, length: { maximum: 1000 }
  enum genre:{
    fiction: 0,
    non_fiction: 1,
    mystery: 2,
    romance: 3,
    sci_fi: 4
  }
end
