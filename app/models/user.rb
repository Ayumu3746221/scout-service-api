class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :validatable, :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  has_one :recruiter, dependent: :destroy
  has_one :student, dependent: :destroy

  enum :role, { student: 0, recruiter: 1 }

  validates :role, presence: true
  validates :role, presence: true, inclusion: { in: roles.keys }

  def name
    case role
    when "student"
      student&.name
    when "recruiter"
      recruiter&.name
    else
      nil
    end
  end

  def company_name
    return nil unless recruiter
    recruiter.company&.name
  end

  def jwt_payload
    payload = {}
    if recruiter? && recruiter&.company.present?
      payload[:company_id] = recruiter.company.id
    end
    payload
  end
end
