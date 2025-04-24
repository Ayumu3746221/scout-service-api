class CreateJobPostingSkills < ActiveRecord::Migration[8.0]
  def change
    create_table :job_posting_skills do |t|
      t.references :job_posting, null: false, foreign_key: true
      t.references :skill, null: false, foreign_key: true

      t.timestamps
    end
    add_index :job_posting_skills, [ :job_posting_id, :skill_id ], unique: true
  end
end
