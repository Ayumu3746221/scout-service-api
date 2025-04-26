class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true, optional: true

  validates :content, presence: true
  validates :is_read, inclusion: { in: [ true, false ] }


  scope :unread, -> { where(is_read: false) }
  scope :read, -> { where(is_read: true) }

  def mark_as_read
    update!(is_read: true)
  end
end
