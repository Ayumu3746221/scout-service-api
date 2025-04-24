class JobPostingSkill < ApplicationRecord
  belongs_to :job_posting
  belongs_to :skill

  validates :job_posting_id, uniqueness: { scope: :skill_id, message: "has already been taken" }
end
