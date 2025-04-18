class CreateJwtDenylists < ActiveRecord::Migration[8.0]
  def change
    create_table :jwt_denylists do |t|
      t.string :jti, null: false  # JSON Web Token ID
      t.datetime :exp, null: false

      t.timestamps
    end
    add_index :jwt_denylists, :jti, unique: true # index -> カラムの索引
  end
end
