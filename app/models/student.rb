class Student < ApplicationRecord
  self.primary_key = :user_id
  belongs_to :user

  has_many :student_industries, dependent: :destroy
  has_many :industries, through: :student_industries

  has_many :student_skills, dependent: :destroy
  has_many :skills, through: :student_skills

  validates :user_id, uniqueness: true
  validates :name, presence: true
  validates :introduce, length: { maximum: 600 }, presence: false
  validates :graduation_year, numericality: { only_integer: true }, allow_nil: true, presence: false
  validates :school, length: { maximum: 100 }, allow_nil: true, presence: false
  validates :portfolio_url, format: { with: URI.regexp(%w[http https]), allow_nil: true }, presence: false
end
