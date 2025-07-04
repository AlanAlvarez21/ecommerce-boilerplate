require 'rails_helper'

RSpec.describe 'Admin::Orders', type: :request do
  let(:admin) { create(:admin) }

  before do
    sign_in admin
  end

  describe 'GET /admin/orders' do
    context 'with various order statuses' do
      let!(:pending_orders) { create_list(:order, 3, :pending, :today) }
      let!(:processing_orders) { create_list(:order, 2, :processing, :yesterday) }
      let!(:delivered_orders) { create_list(:order, 1, :delivered, :this_week) }

      it 'returns success and displays all orders' do
        get '/admin/orders'

        expect(response).to have_http_status(:success)
        expect(response.body).to include('Orders')

        # Check that orders are displayed
        pending_orders.each do |order|
          expect(response.body).to include(order.customer_email)
        end
      end

      it 'shows correct order counts by status' do
        get '/admin/orders'

        # Test that we can see different statuses
        expect(response.body).to include('pending')
        expect(response.body).to include('processing')
        expect(response.body).to include('delivered')
      end
    end

    context 'with pagination' do
      before do
        create_list(:order, 30, :pending)
      end

      it 'paginates orders correctly' do
        get '/admin/orders'

        expect(response).to have_http_status(:success)
        # Should have pagination controls
        expect(response.body).to include('Next') if Order.count > 25
      end
    end
  end

  describe 'GET /admin/orders/:id' do
    let(:order) { create(:order, :processing, :with_products) }

    it 'shows order details' do
      get "/admin/orders/#{order.id}"

      expect(response).to have_http_status(:success)
      expect(response.body).to include(order.customer_email)
      expect(response.body).to include(order.total.to_s)
      expect(response.body).to include(order.status.humanize)
    end

    it 'shows order products' do
      get "/admin/orders/#{order.id}"

      order.order_products.each do |order_product|
        expect(response.body).to include(order_product.product.name)
        expect(response.body).to include(order_product.quantity.to_s)
      end
    end
  end

  describe 'PUT /admin/orders/:id' do
    let(:order) { create(:order, :pending) }

    it 'updates order status successfully' do
      put "/admin/orders/#{order.id}", params: {
        order: { status: 'processing' }
      }

      expect(response).to have_http_status(:redirect)
      expect(order.reload.status).to eq('processing')
    end

    it 'handles invalid status transitions' do
      put "/admin/orders/#{order.id}", params: {
        order: { status: 'invalid_status' }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(order.reload.status).to eq('pending')
    end
  end

  describe 'DELETE /admin/orders/:id' do
    let!(:order) { create(:order, :cancelled) }

    it 'deletes the order' do
      expect {
        delete "/admin/orders/#{order.id}"
      }.to change(Order, :count).by(-1)

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(admin_orders_path)
    end

    it 'prevents deletion of non-cancelled orders' do
      processing_order = create(:order, :processing)

      expect {
        delete "/admin/orders/#{processing_order.id}"
      }.not_to change(Order, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'analytics and reporting' do
    context 'with revenue data' do
      let!(:high_value_orders) { create_list(:order, 2, :delivered, :high_value, :today) }
      let!(:low_value_orders) { create_list(:order, 3, :delivered, :low_value, :yesterday) }

      it 'calculates revenue correctly' do
        get '/admin/orders'

        total_revenue = high_value_orders.sum(&:total) + low_value_orders.sum(&:total)
        expect(response.body).to include(total_revenue.to_s) if total_revenue > 0
      end
    end
  end
end
