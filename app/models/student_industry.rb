class StudentIndustry < ApplicationRecord
  belongs_to :student
  belongs_to :industry

  validates :student_id, uniqueness: { scope: :industry_id, message: "has already been taken" }
end
