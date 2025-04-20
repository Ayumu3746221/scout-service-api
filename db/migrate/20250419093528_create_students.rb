class CreateStudents < ActiveRecord::Migration[8.0]
  def change
    create_table :students, id: false do |t|
      t.references :user, primary_key: true, null: false, foreign_key: true
      t.string :name, null: false
      t.text :introduce
      t.integer :graduation_year
      t.string :school
      t.string :portfolio_url

      t.timestamps
    end
  end
end
