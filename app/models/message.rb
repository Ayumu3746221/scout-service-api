class Message < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"

  validates :content, presence: true
  validate :sender_and_receiver_must_be_different
  validate :only_student_and_recruiter_pairs

  after_create :create_notification

  scope :conversation_between, ->(user1, user2) {
    where(sender_id: user1.id, receiver_id: user2.id)
    .or(where(sender_id: user2.id, receiver_id: user1.id))
    .order(created_at: :asc)
  }

  private

  def sender_and_receiver_must_be_different
    return if sender.nil? || receiver.nil?

    if sender.role == receiver.role
      errors.add(:base, "must be different roles")
    end
  end

  def only_student_and_recruiter_pairs
    return if sender.nil? || receiver.nil?

    unless [ sender.role, receiver.role ].sort == %W[recruiter student].sort
      errors.add(:base, "must be a student and a recruiter")
    end
  end

  def create_notification
    Notification.create(
      user: receiver,
      content: "#{sender.name}さんからメッセージが届きました",
      notifiable: self,
      notification_type: "new_message"
    )
  end
end
