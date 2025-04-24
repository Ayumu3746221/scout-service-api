class Skill < ApplicationRecord
  has_many :student_skills, dependent: :destroy
  has_many :students, through: :student_skills

  has_many :job_posting_skills, dependent: :destroy
  has_many :job_postings, through: :job_posting_skills

  validates :name, presence: true, uniqueness: true

  before_destroy :check_for_students

  private

  def check_for_students
    if students.any?
      errors.add(:base, "Cannot delete skill with associated students")
      throw :abort
    end
  end
end
