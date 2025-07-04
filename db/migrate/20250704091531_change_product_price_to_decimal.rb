class ChangeProductPriceToDecimal < ActiveRecord::Migration[8.0]
  def change
    change_column :products, :price, :decimal, precision: 10, scale: 2, null: false, default: 0
    change_column :orders, :total, :decimal, precision: 10, scale: 2, null: false, default: 0
  end
end
