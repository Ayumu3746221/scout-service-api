class Industry < ApplicationRecord
  has_many :companies

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
