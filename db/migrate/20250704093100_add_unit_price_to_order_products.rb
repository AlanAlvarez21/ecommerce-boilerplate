class AddUnitPriceToOrderProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :order_products, :unit_price, :decimal, precision: 10, scale: 2
    
    # Backfill unit_price from product price
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE order_products 
          SET unit_price = products.price
          FROM products 
          WHERE order_products.product_id = products.id
          AND order_products.unit_price IS NULL
        SQL
      end
    end
    
    change_column_null :order_products, :unit_price, false
  end
end