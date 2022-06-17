class ChangeUserEmailToOptional < ActiveRecord::Migration[5.1]
  def up
    change_column :users, :email, :string, null: true, default: ""
    add_index :users, [:provider, :uid], unique: true
  end

  def down
    change_column :users, :email, :string, null: false, default: ""
    remove_index :users, [:provider, :uid]
  end
end
