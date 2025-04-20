class Industry < ApplicationRecord
  has_many :companies
  has_many :student_industries, dependent: :destroy
  has_many :students, through: :student_industries

  validates :name, presence: true

  before_destroy :check_for_companies

  private

  def check_for_companies
    if companies.exists?
      errors.add(:base, "Cannot delete industry with associated companies")
      throw :abort
    end
  end
end
