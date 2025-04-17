class Company < ApplicationRecord
  has_many :recruiters, dependent: :destroy
  belongs_to :industry

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :address, presence: false
  validates :industry_id, presence: true
  validates :description, presence: false
end
