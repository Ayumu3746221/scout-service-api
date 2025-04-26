class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.text :content
      t.boolean :is_read, default: false
      t.references :notifiable, polymorphic: true
      t.string :notification_type

      t.timestamps
    end
  end
end
