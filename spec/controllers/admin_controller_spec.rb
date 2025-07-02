require 'rails_helper'

RSpec.describe AdminController, type: :controller do
  let(:admin) { create(:admin) }

  before do
    sign_in admin
  end

  describe "GET #index" do
    let!(:fulfilled_order) { create(:order, fulfilled: true, total: 100, created_at: 1.hour.ago) }
    let!(:unfulfilled_orders) { create_list(:order, 7, fulfilled: false, total: 50, created_at: 2.hours.ago) }
    let!(:today_orders) { create_list(:order, 3, fulfilled: true, total: 75, created_at: 30.minutes.ago) }
    
    before do
      # Create order products for per_sale calculation
      today_orders.each do |order|
        create(:order_product, order: order, quantity: 2)
      end
    end

    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "renders the admin layout" do
      get :index
      expect(response).to render_template(layout: "admin")
    end

    it "assigns recent unfulfilled orders" do
      get :index
      expect(assigns(:orders)).to match_array(unfulfilled_orders.take(5))
      expect(assigns(:orders).count).to eq(5)
    end

    it "calculates quick stats for today" do
      get :index
      
      quick_stats = assigns(:quick_stats)
      expect(quick_stats[:sales]).to eq(3) # today_orders count
      expect(quick_stats[:revenue]).to eq(225) # 3 * 75
      expect(quick_stats[:avg_sale]).to eq(75.0)
      expect(quick_stats[:per_sale]).to eq(2.0) # average quantity
    end

    it "calculates revenue by day for last 7 days" do
      get :index
      
      revenue_by_day = assigns(:revenue_by_day)
      expect(revenue_by_day).to be_an(Array)
      expect(revenue_by_day.length).to eq(7)
      
      # Each day should have [day_name, revenue] format
      revenue_by_day.each do |day_data|
        expect(day_data).to be_an(Array)
        expect(day_data.length).to eq(2)
        expect(day_data[0]).to be_a(String) # day name
        expect(day_data[1]).to be_a(Numeric) # revenue
      end
    end

    it "includes today's revenue in revenue_by_day" do
      get :index
      
      revenue_by_day = assigns(:revenue_by_day)
      today_data = revenue_by_day.find { |day| day[0] == Date.today.strftime("%A") }
      
      expect(today_data).to be_present
      expect(today_data[1]).to eq(225) # today's total revenue
    end

    context "when no orders exist" do
      before do
        Order.destroy_all
      end

      it "handles empty data gracefully" do
        get :index
        
        expect(assigns(:orders)).to be_empty
        expect(assigns(:quick_stats)[:sales]).to eq(0)
        expect(assigns(:quick_stats)[:revenue]).to be_nil
        expect(assigns(:revenue_by_day)).to be_an(Array)
      end
    end
  end

  describe "authentication" do
    context "when admin is not signed in" do
      before do
        sign_out admin
      end

      it "redirects to admin sign in" do
        get :index
        expect(response).to redirect_to(new_admin_session_path)
      end
    end
  end
end