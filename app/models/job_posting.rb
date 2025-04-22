class JobPosting < ApplicationRecord
  belongs_to :company

  validates :title, presence: true

  attribute :is_active, :boolean, default: true
end
