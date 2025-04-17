class CreateRecruiters < ActiveRecord::Migration[8.0]
  def change
    create_table :recruiters, id: false do |t|
      t.references :user, null: false, foreign_key: true, primary_key: true
      t.references :company, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
