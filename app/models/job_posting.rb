class JobPosting < ApplicationRecord
  belongs_to :company

  has_many :job_posting_skills, dependent: :destroy
  has_many :skills, through: :job_posting_skills

  has_many :job_posting_industries, dependent: :destroy
  has_many :industries, through: :job_posting_industries

  has_many :apprications, dependent: :destroy
  has_many :applicants, through: :apprications, source: :student

  validates :title, presence: true

  attribute :is_active, :boolean, default: true

  scope :active, -> { where(is_active: true) }
  scope :with_skill, ->(id) { joins(:job_posting_skills).where(job_posting_skills: { skill_id: id }).distinct }
  scope :with_industry, ->(id) { joins(:job_posting_industries).where(job_posting_industries: { industry_id: id }).distinct }
  scope :by_company, ->(company_id) { where(company_id: company_id) }
end
