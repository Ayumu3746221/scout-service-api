class CreateStudentIndustries < ActiveRecord::Migration[8.0]
  def change
    create_table :student_industries do |t|
      t.references :student, null: false, foreign_key: { to_table: :users, primary_key: :id }
      t.references :industry, null: false, foreign_key: true

      t.timestamps
    end

    add_index :student_industries, [ :student_id, :industry_id ], unique: true
  end
end
