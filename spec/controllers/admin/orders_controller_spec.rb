require 'rails_helper'

RSpec.describe Admin::OrdersController, type: :controller do
  let(:admin) { create(:admin) }
  let(:order) { create(:order) }

  before do
    sign_in admin
  end

  describe "GET #index" do
    let!(:fulfilled_orders) { create_list(:order, 3, fulfilled: true) }
    let!(:unfulfilled_orders) { create_list(:order, 2, fulfilled: false) }

    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "renders the admin layout" do
      get :index
      expect(response).to render_template(layout: "admin")
    end

    it "assigns fulfilled orders" do
      get :index

      expect(assigns(:admin_orders)).to be_present
      expect(assigns(:not_fulfilled_orders)).to be_present
    end

    it "paginates fulfilled orders with paid_page parameter" do
      get :index, params: { paid_page: "2" }
      expect(response).to have_http_status(:success)
    end

    it "paginates unfulfilled orders with unpaid_page parameter" do
      get :index, params: { unpaid_page: "3" }
      expect(response).to have_http_status(:success)
    end

    it "limits results to 5 per page" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    it "returns http success" do
      get :show, params: { id: order.id }
      expect(response).to have_http_status(:success)
    end

    it "assigns the requested order" do
      get :show, params: { id: order.id }
      expect(assigns(:admin_order)).to eq(order)
    end

    it "raises error for invalid id" do
      expect {
        get :show, params: { id: 99999 }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end

    it "assigns a new order" do
      get :new
      expect(assigns(:admin_order)).to be_a_new(Order)
    end
  end

  describe "GET #edit" do
    it "returns http success" do
      get :edit, params: { id: order.id }
      expect(response).to have_http_status(:success)
    end

    it "assigns the requested order" do
      get :edit, params: { id: order.id }
      expect(assigns(:admin_order)).to eq(order)
    end
  end

  describe "POST #create" do
    let(:valid_attributes) do
      {
        customer_email: "customer@example.com",
        total: 150.0,
        address: "123 Main St",
        fulfilled: false
      }
    end
    let(:invalid_attributes) { { customer_email: "", total: nil } }

    context "with valid parameters" do
      it "creates a new order" do
        expect {
          post :create, params: { order: valid_attributes }
        }.to change(Order, :count).by(1)
      end

      it "redirects to admin orders index" do
        post :create, params: { order: valid_attributes }
        expect(response).to redirect_to(admin_orders_path(Order.last))
      end

      it "sets a success notice" do
        post :create, params: { order: valid_attributes }
        expect(flash[:notice]).to be_present
      end
    end

    context "with invalid parameters" do
      before do
        allow_any_instance_of(Order).to receive(:save).and_return(false)
        allow_any_instance_of(Order).to receive(:errors).and_return(double(any?: true))
      end

      it "does not create a new order" do
        expect {
          post :create, params: { order: invalid_attributes }
        }.not_to change(Order, :count)
      end

      it "renders the new template" do
        post :create, params: { order: invalid_attributes }
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "JSON format" do
      it "returns created status for valid attributes" do
        post :create, params: { order: valid_attributes }, format: :json
        expect(response).to have_http_status(:created)
      end

      it "returns errors for invalid attributes" do
        allow_any_instance_of(Order).to receive(:save).and_return(false)
        allow_any_instance_of(Order).to receive(:errors).and_return({ customer_email: [ "can't be blank" ] })

        post :create, params: { order: invalid_attributes }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH #update" do
    let(:new_attributes) do
      {
        customer_email: "updated@example.com",
        total: 200.0,
        fulfilled: true
      }
    end
    let(:invalid_attributes) { { customer_email: "" } }

    context "with valid parameters" do
      it "updates the requested order" do
        patch :update, params: { id: order.id, order: new_attributes }
        order.reload
        expect(order.customer_email).to eq("updated@example.com")
        expect(order.total).to eq(200.0)
        expect(order.fulfilled).to be_truthy
      end

      it "redirects to admin orders index" do
        patch :update, params: { id: order.id, order: new_attributes }
        expect(response).to redirect_to(admin_orders_path(order))
      end

      it "sets a success notice" do
        patch :update, params: { id: order.id, order: new_attributes }
        expect(flash[:notice]).to be_present
      end
    end

    context "with invalid parameters" do
      it "renders the edit template" do
        patch :update, params: { id: order.id, order: invalid_attributes }
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "JSON format" do
      it "returns ok status for valid attributes" do
        patch :update, params: { id: order.id, order: new_attributes }, format: :json
        expect(response).to have_http_status(:ok)
      end

      it "returns errors for invalid attributes" do
        patch :update, params: { id: order.id, order: invalid_attributes }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:order_to_delete) { create(:order) }

    it "destroys the requested order" do
      expect {
        delete :destroy, params: { id: order_to_delete.id }
      }.to change(Order, :count).by(-1)
    end

    it "redirects to admin orders index" do
      delete :destroy, params: { id: order_to_delete.id }
      expect(response).to redirect_to(admin_orders_path)
      expect(response).to have_http_status(:see_other)
    end

    it "sets a success notice" do
      delete :destroy, params: { id: order_to_delete.id }
      expect(flash[:notice]).to be_present
    end

    context "JSON format" do
      it "returns no content status" do
        delete :destroy, params: { id: order_to_delete.id }, format: :json
        expect(response).to have_http_status(:no_content)
      end
    end
  end

  describe "authentication" do
    context "when admin is not signed in" do
      before do
        sign_out admin
      end

      it "redirects to admin sign in for index" do
        get :index
        expect(response.location).to include("/admins/sign_in")
      end

      it "redirects to admin sign in for show" do
        get :show, params: { id: order.id }
        expect(response.location).to include("/admins/sign_in")
      end
    end
  end

  describe "private methods" do
    describe "#set_order" do
      it "sets @admin_order for show action" do
        get :show, params: { id: order.id }
        expect(assigns(:admin_order)).to eq(order)
      end
    end

    describe "#order_params" do
      it "permits allowed parameters" do
        params = ActionController::Parameters.new(
          order: {
            customer_email: "test@example.com",
            fulfilled: true,
            total: 100.0,
            address: "123 Main St",
            forbidden_param: "not allowed"
          }
        )

        controller.params = params
        permitted_params = controller.send(:order_params)

        expect(permitted_params.permitted?).to be true
        expect(permitted_params.keys).to match_array(%w[customer_email fulfilled total address])
      end
    end
  end
end
