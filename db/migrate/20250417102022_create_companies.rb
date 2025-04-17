class CreateCompanies < ActiveRecord::Migration[8.0]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :email
      t.string :address
      t.references :industry, null: false, foreign_key: true
      t.string :discription

      t.timestamps
    end
  end
end
