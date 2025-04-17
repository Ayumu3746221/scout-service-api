class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :validatable, :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist
  enum :role, { student: 0, recruiter: 1 }
  validates :role, presence: true
end
