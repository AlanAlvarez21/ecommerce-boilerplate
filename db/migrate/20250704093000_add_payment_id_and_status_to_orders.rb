class AddPaymentIdAndStatusToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :payment_id, :string
    add_column :orders, :status, :integer, default: 0, null: false
    add_index :orders, :payment_id
    add_index :orders, :status

    # Migrate existing data
    reversible do |dir|
      dir.up do
        # Convert fulfilled boolean to status enum
        execute <<-SQL
          UPDATE orders#{' '}
          SET status = CASE#{' '}
            WHEN fulfilled = true THEN 3
            WHEN fulfilled = false THEN 0
            ELSE 0
          END
        SQL
      end
    end
  end
end
