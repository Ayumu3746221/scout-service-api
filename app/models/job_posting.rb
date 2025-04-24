class JobPosting < ApplicationRecord
  belongs_to :company

  has_many :job_posting_skills, dependent: :destroy
  has_many :skills, through: :job_posting_skills

  has_many :job_posting_industries, dependent: :destroy
  has_many :industries, through: :job_posting_industries

  validates :title, presence: true

  attribute :is_active, :boolean, default: true
end
