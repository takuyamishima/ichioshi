class AddColumnReviews < ActiveRecord::Migration[5.2]
  def change
    add_column :reviews, :category_name, :string
  end
end
