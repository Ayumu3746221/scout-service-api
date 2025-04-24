class JobPostingIndustry < ApplicationRecord
  belongs_to :job_posting
  belongs_to :industry

  validates :job_posting_id, uniqueness: { scope: :industry_id, message: "has already been taken" }
end
