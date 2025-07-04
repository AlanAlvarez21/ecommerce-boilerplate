require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'validations' do
    it 'validates presence of customer_email' do
      order = build(:order, customer_email: nil)
      expect(order).not_to be_valid
      expect(order.errors[:customer_email]).to include("can't be blank")
    end

    it 'validates presence of total' do
      order = build(:order, total: nil)
      expect(order).not_to be_valid
      expect(order.errors[:total]).to include("can't be blank")
    end

    it 'validates presence of address' do
      order = build(:order, address: nil)
      expect(order).not_to be_valid
      expect(order.errors[:address]).to include("can't be blank")
    end

    it 'validates total is greater than 0' do
      order = build(:order, total: 0)
      expect(order).not_to be_valid
      expect(order.errors[:total]).to include("must be greater than 0")
    end

    it 'validates email format' do
      invalid_order = build(:order, customer_email: 'invalid-email')
      expect(invalid_order).not_to be_valid
      expect(invalid_order.errors[:customer_email]).to include('is not a valid email address')
    end
  end

  describe 'associations' do
    it 'has many order_products' do
      order = create(:order)
      expect(order).to respond_to(:order_products)
    end

    it 'has many products through order_products' do
      order = create(:order)
      expect(order).to respond_to(:products)
    end
  end

  describe 'enums' do
    it 'defines status enum' do
      expect(Order.statuses).to eq({
        "pending" => 0,
        "processing" => 1,
        "shipped" => 2,
        "delivered" => 3,
        "cancelled" => 4
      })
    end

    it 'has correct default status' do
      order = build(:order)
      expect(order.status).to eq('pending')
    end
  end

  describe 'scopes' do
    let!(:today_orders) { create_list(:order, 3, :today) }
    let!(:yesterday_orders) { create_list(:order, 2, :yesterday) }
    let!(:week_orders) { create_list(:order, 1, :this_week) }

    describe '.today' do
      it 'returns orders created today' do
        expect(Order.today).to match_array(today_orders)
      end
    end

    describe '.recent' do
      it 'returns orders in descending order by creation date' do
        recent_orders = Order.recent
        expect(recent_orders.first.created_at).to be >= recent_orders.last.created_at
      end
    end

    describe 'status scopes' do
      before do
        Order.delete_all
      end

      let!(:pending_orders) { create_list(:order, 2, :pending) }
      let!(:processing_orders) { create_list(:order, 1, :processing) }
      let!(:delivered_orders) { create_list(:order, 1, :delivered) }

      it 'filters by pending status' do
        expect(Order.pending.count).to eq(2)
        expect(Order.pending.pluck(:status).uniq).to eq([ 'pending' ])
      end

      it 'filters by processing status' do
        expect(Order.processing.count).to eq(1)
        expect(Order.processing.pluck(:status).uniq).to eq([ 'processing' ])
      end

      it 'filters by delivered status' do
        expect(Order.delivered.count).to eq(1)
        expect(Order.delivered.pluck(:status).uniq).to eq([ 'delivered' ])
      end
    end
  end

  describe 'class methods' do
    describe '.revenue_by_day' do
      before do
        # Clear any existing orders from previous tests
        Order.delete_all
      end

      let!(:today_orders) { create_list(:order, 2, :delivered, :today, total: 100.00) }
      let!(:yesterday_orders) { create_list(:order, 1, :delivered, :yesterday, total: 50.00) }

      it 'calculates revenue correctly' do
        revenue_data = Order.revenue_by_day(2)

        expect(revenue_data).to be_a(Hash)
        expect(revenue_data[Date.current]).to eq(200.00)
        expect(revenue_data[Date.yesterday]).to eq(50.00)
      end

      it 'only includes delivered orders' do
        create(:order, :pending, :today, total: 1000.00)

        revenue_data = Order.revenue_by_day(1)
        expect(revenue_data[Date.current]).to eq(200.00) # Only delivered orders
      end
    end

    describe '.count_for_period' do
      let!(:period_orders) { create_list(:order, 3, :today) }

      it 'counts orders in given period' do
        start_time = Time.current.beginning_of_day
        end_time = Time.current.end_of_day

        count = Order.count_for_period(start_time, end_time)
        expect(count).to eq(3)
      end
    end

    describe '.revenue_for_period' do
      let!(:delivered_orders) { create_list(:order, 2, :delivered, :today, total: 75.50) }
      let!(:pending_orders) { create_list(:order, 1, :pending, :today, total: 100.00) }

      it 'calculates revenue only for delivered orders' do
        start_time = Time.current.beginning_of_day
        end_time = Time.current.end_of_day

        revenue = Order.revenue_for_period(start_time, end_time)
        expect(revenue).to eq(151.00) # Only delivered orders: 75.50 * 2 = 151.00
      end
    end

    describe '.average_order_value_for_period' do
      let!(:delivered_orders) { create_list(:order, 2, :delivered, :today, total: 100.00) }

      it 'calculates average order value' do
        start_time = Time.current.beginning_of_day
        end_time = Time.current.end_of_day

        avg = Order.average_order_value_for_period(start_time, end_time)
        expect(avg).to eq(100.00)
      end
    end
  end

  describe 'instance methods' do
    describe '#total_items' do
      let(:order) { create(:order, :with_products) }

      it 'calculates total items correctly' do
        total = order.order_products.sum(&:quantity)
        expect(order.total_items).to eq(total)
      end
    end

    describe '#can_be_cancelled?' do
      it 'returns true for pending orders' do
        order = create(:order, :pending)
        expect(order.can_be_cancelled?).to be true
      end

      it 'returns false for delivered orders' do
        order = create(:order, :delivered)
        expect(order.can_be_cancelled?).to be false
      end
    end

    describe '#formatted_total' do
      let(:order) { create(:order, total: 123.45) }

      it 'formats total as currency' do
        expect(order.formatted_total).to eq('$123.45')
      end
    end
  end

  describe 'callbacks' do
    describe 'before_save' do
      it 'normalizes email to lowercase' do
        order = create(:order, customer_email: 'TEST@EXAMPLE.COM')
        expect(order.customer_email).to eq('test@example.com')
      end
    end

    describe 'after_create' do
      it 'generates payment_id if not present' do
        order = build(:order, payment_id: nil)
        order.save!

        expect(order.payment_id).to be_present
        expect(order.payment_id).to start_with('ORD-')
      end
    end
  end

  describe 'factory traits' do
    describe 'status traits' do
      it 'creates pending order' do
        order = create(:order, :pending)
        expect(order.status).to eq('pending')
      end

      it 'creates processing order' do
        order = create(:order, :processing)
        expect(order.status).to eq('processing')
      end

      it 'creates delivered order' do
        order = create(:order, :delivered)
        expect(order.status).to eq('delivered')
      end
    end

    describe 'time traits' do
      it 'creates today order' do
        order = create(:order, :today)
        expect(order.created_at.to_date).to eq(Date.current)
      end

      it 'creates yesterday order' do
        order = create(:order, :yesterday)
        expect(order.created_at.to_date).to eq(Date.yesterday)
      end
    end

    describe 'value traits' do
      it 'creates high value order' do
        order = create(:order, :high_value)
        expect(order.total).to be > 1000.0
      end

      it 'creates low value order' do
        order = create(:order, :low_value)
        expect(order.total).to be < 100.0
      end
    end
  end
end
