class CreateApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :applications do |t|
      t.references :job_posting, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: { to_table: :users }
      t.text :message
      t.string :status

      t.timestamps
    end

    add_index :applications, [ :job_posting_id, :student_id ], unique: true
  end
end
