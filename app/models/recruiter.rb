class Recruiter < ApplicationRecord
  belongs_to :user
  belongs_to :company

  validates :user_id, uniqueness: true
  validates :name, presence: true
end
