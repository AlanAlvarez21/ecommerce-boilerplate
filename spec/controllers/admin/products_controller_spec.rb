require 'rails_helper'

RSpec.describe Admin::ProductsController, type: :controller do
  let(:admin) { create(:admin) }
  let(:category) { create(:category) }
  let(:product) { create(:product, category: category) }

  before do
    sign_in admin
  end

  describe "GET #index" do
    let!(:products) { create_list(:product, 3, category: category) }

    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "renders the admin layout" do
      get :index
      expect(response).to render_template(layout: "admin")
    end

    it "assigns all products" do
      get :index
      expect(assigns(:admin_products)).to match_array(products)
    end
  end

  describe "GET #show" do
    it "returns http success" do
      get :show, params: { id: product.id }
      expect(response).to have_http_status(:success)
    end

    it "assigns the requested product" do
      get :show, params: { id: product.id }
      expect(assigns(:admin_product)).to eq(product)
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

    it "assigns a new product" do
      get :new
      expect(assigns(:admin_product)).to be_a_new(Product)
    end
  end

  describe "GET #edit" do
    it "returns http success" do
      get :edit, params: { id: product.id }
      expect(response).to have_http_status(:success)
    end

    it "assigns the requested product" do
      get :edit, params: { id: product.id }
      expect(assigns(:admin_product)).to eq(product)
    end
  end

  describe "POST #create" do
    let(:valid_attributes) do
      {
        name: "New Product",
        description: "Product description",
        price: 99.99,
        category_id: category.id,
        active: true
      }
    end
    let(:invalid_attributes) { { name: "", price: nil } }

    context "with valid parameters" do
      it "creates a new product" do
        expect {
          post :create, params: { product: valid_attributes }
        }.to change(Product, :count).by(1)
      end

      it "redirects to admin products index" do
        post :create, params: { product: valid_attributes }
        expect(response).to redirect_to(admin_products_path(Product.last))
      end

      it "sets a success notice" do
        post :create, params: { product: valid_attributes }
        expect(flash[:notice]).to be_present
      end
    end

    context "with invalid parameters" do
      before do
        allow_any_instance_of(Product).to receive(:save).and_return(false)
        allow_any_instance_of(Product).to receive(:errors).and_return(double(any?: true))
      end

      it "does not create a new product" do
        expect {
          post :create, params: { product: invalid_attributes }
        }.not_to change(Product, :count)
      end

      it "renders the new template" do
        post :create, params: { product: invalid_attributes }
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "JSON format" do
      it "returns created status for valid attributes" do
        post :create, params: { product: valid_attributes }, format: :json
        expect(response).to have_http_status(:created)
      end

      it "returns errors for invalid attributes" do
        allow_any_instance_of(Product).to receive(:save).and_return(false)
        allow_any_instance_of(Product).to receive(:errors).and_return({ name: [ "can't be blank" ] })

        post :create, params: { product: invalid_attributes }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH #update" do
    let(:new_attributes) do
      {
        name: "Updated Product",
        description: "Updated description",
        price: 149.99
      }
    end
    let(:invalid_attributes) { { name: "" } }

    # Note: This controller has duplicate update logic - testing the first implementation
    context "with valid parameters (first update logic)" do
      it "updates the requested product" do
        patch :update, params: { id: product.id, product: new_attributes }
        product.reload
        expect(product.name).to eq("Updated Product")
        expect(product.description).to eq("Updated description")
        expect(product.price).to eq(149.99)
      end

      it "redirects to admin products index" do
        patch :update, params: { id: product.id, product: new_attributes }
        expect(response).to redirect_to(admin_products_path(product))
      end

      it "sets a success notice" do
        patch :update, params: { id: product.id, product: new_attributes }
        expect(flash[:notice]).to be_present
      end
    end

    context "with invalid parameters" do
      it "renders the edit template" do
        patch :update, params: { id: product.id, product: invalid_attributes }
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "JSON format" do
      it "returns ok status for valid attributes" do
        patch :update, params: { id: product.id, product: new_attributes }, format: :json
        expect(response).to have_http_status(:ok)
      end

      it "returns errors for invalid attributes" do
        patch :update, params: { id: product.id, product: invalid_attributes }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with image attachments" do
      let(:image_file) { fixture_file_upload('test_image.jpg', 'image/jpeg') }
      let(:attributes_with_images) { new_attributes.merge(images: [ image_file ]) }

      before do
        # Create a test image file fixture
        allow(product).to receive_message_chain(:images, :attach)
      end

      # Note: The duplicate update logic in the controller makes this complex to test
      # The controller has both respond_to blocks and standalone logic
      it "handles image attachments in the update logic" do
        patch :update, params: { id: product.id, product: attributes_with_images }
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:product_to_delete) { create(:product, category: category) }

    it "destroys the requested product" do
      expect {
        delete :destroy, params: { id: product_to_delete.id }
      }.to change(Product, :count).by(-1)
    end

    it "redirects to admin products index" do
      delete :destroy, params: { id: product_to_delete.id }
      expect(response).to redirect_to(admin_products_path(product_to_delete))
      expect(response).to have_http_status(:see_other)
    end

    it "sets a success notice" do
      delete :destroy, params: { id: product_to_delete.id }
      expect(flash[:notice]).to be_present
    end

    context "JSON format" do
      it "returns no content status" do
        delete :destroy, params: { id: product_to_delete.id }, format: :json
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
        get :show, params: { id: product.id }
        expect(response.location).to include("/admins/sign_in")
      end
    end
  end

  describe "private methods" do
    describe "#set_admin_product" do
      it "sets @admin_product for show action" do
        get :show, params: { id: product.id }
        expect(assigns(:admin_product)).to eq(product)
      end
    end

    describe "#admin_product_params" do
      it "permits allowed parameters" do
        params = ActionController::Parameters.new(
          product: {
            name: "Test",
            description: "Test desc",
            price: 99.99,
            category_id: category.id,
            active: true,
            image_url: "http://example.com/test.jpg",
            images: [ "test1.jpg", "test2.jpg" ],
            forbidden_param: "not allowed"
          }
        )

        controller.params = params
        permitted_params = controller.send(:admin_product_params)

        expect(permitted_params.permitted?).to be true
        expect(permitted_params.keys).to match_array(%w[name description price category_id active image_url images])
      end
    end
  end
end
