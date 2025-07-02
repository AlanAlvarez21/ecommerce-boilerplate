require 'rails_helper'

RSpec.describe CheckoutsController, type: :controller do
  let(:product) { create(:product) }
  let(:stock) { create(:stock, product: product, size: "M", amount: 10) }
  let(:mercado_pago_service) { instance_double(MercadoPagoSdk) }
  
  before do
    stock
    allow(MercadoPagoSdk).to receive(:new).and_return(mercado_pago_service)
  end

  describe "POST #create" do
    let(:valid_cart_params) do
      {
        cart: [
          {
            id: product.id.to_s,
            name: product.name,
            price: product.price.to_s,
            quantity: "2",
            size: "M"
          }
        ],
        email: "test@example.com",
        zip_code: "12345",
        street_name: "Main St",
        street_number: "123",
        identification_number: "123456789",
        identification_type: "DNI"
      }
    end

    context "with valid parameters and sufficient stock" do
      before do
        allow(mercado_pago_service).to receive(:create_preference).and_return("https://payment-url.com")
      end

      it "redirects to payment URL" do
        post :create, params: valid_cart_params
        expect(response).to redirect_to("https://payment-url.com")
      end

      it "calls MercadoPago service with correct parameters" do
        expected_line_items = [
          {
            title: product.name,
            quantity: 2,
            currency_id: "MXN",
            unit_price: product.price.to_f,
            category_id: "others"
          }
        ]
        expected_user_info = {
          email: "test@example.com",
          zip_code: "12345",
          street_name: "Main St",
          street_number: "123",
          identification_number: "123456789",
          identification_type: "DNI"
        }

        expect(mercado_pago_service).to receive(:create_preference)
          .with(expected_line_items, expected_user_info)
          .and_return("https://payment-url.com")
        
        post :create, params: valid_cart_params
      end
    end

    context "with insufficient stock" do
      let(:insufficient_cart_params) do
        valid_cart_params.deep_merge(
          cart: [{ quantity: "15" }]
        )
      end

      it "returns 400 status with error message" do
        post :create, params: insufficient_cart_params
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)["error"]).to include("stock")
      end
    end

    context "when MercadoPago service fails" do
      before do
        allow(mercado_pago_service).to receive(:create_preference).and_raise(StandardError.new("Payment service error"))
      end

      it "redirects to cart with error message" do
        post :create, params: valid_cart_params
        expect(response).to redirect_to(cart_path)
        expect(flash[:alert]).to include("Payment service error")
      end
    end

    context "when payment URL is blank" do
      before do
        allow(mercado_pago_service).to receive(:create_preference).and_return(nil)
      end

      it "redirects to cart with error message" do
        post :create, params: valid_cart_params
        expect(response).to redirect_to(cart_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "GET #success" do
    let(:success_params) do
      {
        payment_id: "123456",
        status: "approved",
        external_reference: "ref123",
        merchant_order_id: "order123"
      }
    end

    it "returns http success" do
      get :success, params: success_params
      expect(response).to have_http_status(:success)
    end

    it "renders the success template" do
      get :success, params: success_params
      expect(response).to render_template(:success)
    end
  end

  describe "GET #failure" do
    it "returns http success" do
      get :failure
      expect(response).to have_http_status(:success)
    end

    it "renders the failure template" do
      get :failure
      expect(response).to render_template(:failure)
    end
  end

  describe "GET #pending" do
    it "returns http success" do
      get :pending
      expect(response).to have_http_status(:success)
    end

    it "renders the pending template" do
      get :pending
      expect(response).to render_template(:pending)
    end
  end
end