class AddFieldsToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :short_bio, :string
    add_column :users, :age, :integer
    add_column :users, :location, :string
    add_column :users, :gender, :integer
  end
end
