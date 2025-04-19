class StudentSkill < ApplicationRecord
  belongs_to :student
  belongs_to :skill

  validates :student_id, uniqueness: { scope: :skill_id, message: "has already been taken" }
end
