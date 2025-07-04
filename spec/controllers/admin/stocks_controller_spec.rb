require 'rails_helper'

RSpec.describe Admin::StocksController, type: :controller do
  let(:admin) { create(:admin) }
  let(:product) { create(:product) }
  let(:stock) { create(:stock, product: product) }

  before do
    sign_in admin
  end

  describe "GET #index" do
    let!(:stocks) { create_list(:stock, 3, product: product) }
    let!(:other_product_stocks) { create_list(:stock, 2) }

    it "returns http success" do
      get :index, params: { product_id: product.id }
      expect(response).to have_http_status(:success)
    end

    it "renders the admin layout" do
      get :index, params: { product_id: product.id }
      expect(response).to render_template(layout: "admin")
    end

    it "assigns only stocks for the specified product" do
      get :index, params: { product_id: product.id }
      expect(assigns(:admin_stocks)).to match_array(stocks)
      expect(assigns(:admin_stocks)).not_to include(*other_product_stocks)
    end

    it "orders stocks by created_at desc" do
      old_stock = create(:stock, product: product, created_at: 1.day.ago)
      new_stock = create(:stock, product: product, created_at: 1.hour.ago)

      get :index, params: { product_id: product.id }

      stocks_in_order = assigns(:admin_stocks).to_a
      expect(stocks_in_order.first.created_at).to be > stocks_in_order.last.created_at
    end
  end

  describe "GET #show" do
    it "returns http success" do
      get :show, params: { product_id: product.id, id: stock.id }
      expect(response).to have_http_status(:success)
    end

    it "assigns the requested stock" do
      get :show, params: { product_id: product.id, id: stock.id }
      expect(assigns(:admin_stock)).to eq(stock)
    end

    it "raises error for invalid id" do
      expect {
        get :show, params: { product_id: product.id, id: 99999 }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET #new" do
    it "returns http success" do
      get :new, params: { product_id: product.id }
      expect(response).to have_http_status(:success)
    end

    it "assigns a new stock" do
      get :new, params: { product_id: product.id }
      expect(assigns(:admin_stock)).to be_a_new(Stock)
    end

    it "assigns the product" do
      get :new, params: { product_id: product.id }
      expect(assigns(:product)).to eq(product)
    end

    it "raises error for invalid product_id" do
      expect {
        get :new, params: { product_id: 99999 }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET #edit" do
    it "returns http success" do
      get :edit, params: { product_id: product.id, id: stock.id }
      expect(response).to have_http_status(:success)
    end

    it "assigns the requested stock" do
      get :edit, params: { product_id: product.id, id: stock.id }
      expect(assigns(:admin_stock)).to eq(stock)
    end

    it "assigns the product" do
      get :edit, params: { product_id: product.id, id: stock.id }
      expect(assigns(:product)).to eq(product)
    end
  end

  describe "POST #create" do
    let(:valid_attributes) { { amount: 50, size: "XL" } }
    let(:invalid_attributes) { { amount: nil, size: "" } }

    context "with valid parameters" do
      it "creates a new stock" do
        expect {
          post :create, params: { product_id: product.id, stock: valid_attributes }
        }.to change(Stock, :count).by(1)
      end

      it "associates stock with the product" do
        post :create, params: { product_id: product.id, stock: valid_attributes }
        expect(Stock.last.product).to eq(product)
      end

      it "redirects to admin product stock path" do
        post :create, params: { product_id: product.id, stock: valid_attributes }
        stock = Stock.last
        expect(response).to redirect_to(admin_product_stock_path(product, stock))
      end

      it "sets a success notice" do
        post :create, params: { product_id: product.id, stock: valid_attributes }
        expect(flash[:notice]).to be_present
      end
    end

    context "with invalid parameters" do
      before do
        allow_any_instance_of(Stock).to receive(:save).and_return(false)
        allow_any_instance_of(Stock).to receive(:errors).and_return(double(any?: true))
      end

      it "does not create a new stock" do
        expect {
          post :create, params: { product_id: product.id, stock: invalid_attributes }
        }.not_to change(Stock, :count)
      end

      it "renders the new template" do
        post :create, params: { product_id: product.id, stock: invalid_attributes }
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "assigns the product" do
        post :create, params: { product_id: product.id, stock: invalid_attributes }
        expect(assigns(:product)).to eq(product)
      end
    end

    context "JSON format" do
      it "returns created status for valid attributes" do
        post :create, params: { product_id: product.id, stock: valid_attributes }, format: :json
        expect(response).to have_http_status(:created)
      end

      it "returns errors for invalid attributes" do
        allow_any_instance_of(Stock).to receive(:save).and_return(false)
        allow_any_instance_of(Stock).to receive(:errors).and_return({ amount: [ "can't be blank" ] })

        post :create, params: { product_id: product.id, stock: invalid_attributes }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH #update" do
    let(:new_attributes) { { amount: 75, size: "XXL" } }
    let(:invalid_attributes) { { amount: nil } }

    context "with valid parameters" do
      it "updates the requested stock" do
        patch :update, params: { product_id: product.id, id: stock.id, stock: new_attributes }
        stock.reload
        expect(stock.amount).to eq(75)
        expect(stock.size).to eq("XXL")
      end

      it "redirects to admin product stocks path" do
        patch :update, params: { product_id: product.id, id: stock.id, stock: new_attributes }
        expect(response).to redirect_to(admin_product_stocks_path(stock.product, stock))
      end

      it "sets a success notice" do
        patch :update, params: { product_id: product.id, id: stock.id, stock: new_attributes }
        expect(flash[:notice]).to be_present
      end
    end

    context "with invalid parameters" do
      it "renders the edit template" do
        patch :update, params: { product_id: product.id, id: stock.id, stock: invalid_attributes }
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "JSON format" do
      it "returns ok status for valid attributes" do
        patch :update, params: { product_id: product.id, id: stock.id, stock: new_attributes }, format: :json
        expect(response).to have_http_status(:ok)
      end

      it "returns errors for invalid attributes" do
        patch :update, params: { product_id: product.id, id: stock.id, stock: invalid_attributes }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:stock_to_delete) { create(:stock, product: product) }

    it "destroys the requested stock" do
      expect {
        delete :destroy, params: { product_id: product.id, id: stock_to_delete.id }
      }.to change(Stock, :count).by(-1)
    end

    it "redirects to admin product stocks path" do
      delete :destroy, params: { product_id: product.id, id: stock_to_delete.id }
      expect(response).to redirect_to(admin_product_stocks_path(stock_to_delete.product, stock_to_delete))
      expect(response).to have_http_status(:see_other)
    end

    it "sets a success notice" do
      delete :destroy, params: { product_id: product.id, id: stock_to_delete.id }
      expect(flash[:notice]).to be_present
    end

    context "JSON format" do
      it "returns no content status" do
        delete :destroy, params: { product_id: product.id, id: stock_to_delete.id }, format: :json
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
        get :index, params: { product_id: product.id }
        expect(response.location).to include("/admins/sign_in")
      end

      it "redirects to admin sign in for show" do
        get :show, params: { product_id: product.id, id: stock.id }
        expect(response.location).to include("/admins/sign_in")
      end
    end
  end

  describe "private methods" do
    describe "#set_stock" do
      it "sets @admin_stock for show action" do
        get :show, params: { product_id: product.id, id: stock.id }
        expect(assigns(:admin_stock)).to eq(stock)
      end
    end

    describe "#stock_params" do
      it "permits allowed parameters" do
        params = ActionController::Parameters.new(
          stock: {
            amount: 100,
            size: "L",
            forbidden_param: "not allowed"
          }
        )

        controller.params = params
        permitted_params = controller.send(:stock_params)

        expect(permitted_params.permitted?).to be true
        expect(permitted_params.keys).to match_array(%w[amount size])
      end
    end
  end
end
