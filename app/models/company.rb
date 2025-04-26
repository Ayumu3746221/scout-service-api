class Company < ApplicationRecord
  has_many :recruiters, dependent: :destroy
  has_many :job_postings, dependent: :destroy
  belongs_to :industry

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :address, presence: false
  validates :industry_id, presence: true
  validates :description, presence: false

  scope :with_industry, ->(id) { where(industry_id: id) }
end
