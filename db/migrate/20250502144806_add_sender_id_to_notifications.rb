class AddSenderIdToNotifications < ActiveRecord::Migration[8.0]
  def change
    add_column :notifications, :sender_id, :integer
    add_index :notifications, :sender_id
  end
end
