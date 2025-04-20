class CreateStudentSkills < ActiveRecord::Migration[8.0]
  def change
    create_table :student_skills do |t|
      t.references :student, null: false, foreign_key: { to_table: :users, primary_key: :id }
      t.references :skill, null: false, foreign_key: true

      t.timestamps
    end

    add_index :student_skills, [ :student_id, :skill_id ], unique: true
  end
end
