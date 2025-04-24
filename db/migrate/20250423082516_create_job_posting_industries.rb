class CreateJobPostingIndustries < ActiveRecord::Migration[8.0]
  def change
    create_table :job_posting_industries do |t|
      t.references :job_posting, null: false, foreign_key: true
      t.references :industry, null: false, foreign_key: true

      t.timestamps
    end
    add_index :job_posting_industries, [ :job_posting_id, :industry_id ], unique: true
  end
end
