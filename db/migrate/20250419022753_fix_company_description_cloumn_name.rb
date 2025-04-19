class FixCompanyDescriptionCloumnName < ActiveRecord::Migration[8.0]
  def change
    rename_column :companies, :discription, :description
  end
end
