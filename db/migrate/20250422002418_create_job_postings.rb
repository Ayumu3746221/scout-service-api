class CreateJobPostings < ActiveRecord::Migration[8.0]
  def change
    create_table :job_postings do |t|
      t.references :company, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.text :requirements
      t.boolean :is_active, default: false

      t.timestamps
    end
  end
end
