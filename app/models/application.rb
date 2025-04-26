class Application < ApplicationRecord
  belongs_to :job_posting
  belongs_to :student
  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :student_id, uniqueness: { scope: :job_posting_id, message: "has already applied to this job posting" }
  validates :status, inclusion: { in: %w[pending accepted rejected] }

  attribute :status, :string, default: "pending"
  after_create :create_notification_for_recruiter

  def create_notification_for_recruiter
    company_id = job_posting.company_id

    recruiter = Recruiter.where(company_id: company_id)

    recruiter.each do |recruiter|
      Notification.create(
        user: recruiter.user,
        content: "#{student.name} さんが「#{job_posting.title}」に応募しました。",
        notifiable: self,
        notifiable_type: "new_application",
      )
    end
  end
end
