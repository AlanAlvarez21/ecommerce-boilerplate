require 'rails_helper'

RSpec.describe Admin::CategoriesController, type: :controller do
  let(:admin) { create(:admin) }
  let(:category) { create(:category) }

  before do
    sign_in admin
  end

  describe "GET #index" do
    let!(:categories) { create_list(:category, 3) }

    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "renders the admin layout" do
      get :index
      expect(response).to render_template(layout: "admin")
    end

    it "assigns all categories" do
      get :index
      expect(assigns(:categories)).to match_array(categories)
    end
  end

  describe "GET #show" do
    it "returns http success" do
      get :show, params: { id: category.id }
      expect(response).to have_http_status(:success)
    end

    it "assigns the requested category" do
      get :show, params: { id: category.id }
      expect(assigns(:category)).to eq(category)
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

    it "assigns a new category" do
      get :new
      expect(assigns(:category)).to be_a_new(Category)
    end
  end

  describe "GET #edit" do
    it "returns http success" do
      get :edit, params: { id: category.id }
      expect(response).to have_http_status(:success)
    end

    it "assigns the requested category" do
      get :edit, params: { id: category.id }
      expect(assigns(:category)).to eq(category)
    end
  end

  describe "POST #create" do
    let(:valid_attributes) { { name: "New Category", description: "Category description" } }
    let(:invalid_attributes) { { name: "", description: "" } }

    context "with valid parameters" do
      it "creates a new category" do
        expect {
          post :create, params: { category: valid_attributes }
        }.to change(Category, :count).by(1)
      end

      it "redirects to admin categories index" do
        post :create, params: { category: valid_attributes }
        expect(response).to redirect_to(admin_categories_path(Category.last))
      end

      it "sets a success notice" do
        post :create, params: { category: valid_attributes }
        expect(flash[:notice]).to be_present
      end
    end

    context "with invalid parameters" do
      before do
        allow_any_instance_of(Category).to receive(:save).and_return(false)
        allow_any_instance_of(Category).to receive(:errors).and_return(double(any?: true))
      end

      it "does not create a new category" do
        expect {
          post :create, params: { category: invalid_attributes }
        }.not_to change(Category, :count)
      end

      it "renders the new template" do
        post :create, params: { category: invalid_attributes }
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "JSON format" do
      it "returns created status for valid attributes" do
        post :create, params: { category: valid_attributes }, format: :json
        expect(response).to have_http_status(:created)
      end

      it "returns errors for invalid attributes" do
        allow_any_instance_of(Category).to receive(:save).and_return(false)
        allow_any_instance_of(Category).to receive(:errors).and_return({ name: ["can't be blank"] })
        
        post :create, params: { category: invalid_attributes }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH #update" do
    let(:new_attributes) { { name: "Updated Category", description: "Updated description" } }
    let(:invalid_attributes) { { name: "" } }

    context "with valid parameters" do
      it "updates the requested category" do
        patch :update, params: { id: category.id, category: new_attributes }
        category.reload
        expect(category.name).to eq("Updated Category")
        expect(category.description).to eq("Updated description")
      end

      it "redirects to admin categories index" do
        patch :update, params: { id: category.id, category: new_attributes }
        expect(response).to redirect_to(admin_categories_path(category))
      end

      it "sets a success notice" do
        patch :update, params: { id: category.id, category: new_attributes }
        expect(flash[:notice]).to be_present
      end
    end

    context "with invalid parameters" do
      before do
        allow_any_instance_of(Category).to receive(:update).and_return(false)
        allow_any_instance_of(Category).to receive(:errors).and_return(double(any?: true))
      end

      it "renders the edit template" do
        patch :update, params: { id: category.id, category: invalid_attributes }
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "JSON format" do
      it "returns ok status for valid attributes" do
        patch :update, params: { id: category.id, category: new_attributes }, format: :json
        expect(response).to have_http_status(:ok)
      end

      it "returns errors for invalid attributes" do
        allow_any_instance_of(Category).to receive(:update).and_return(false)
        allow_any_instance_of(Category).to receive(:errors).and_return({ name: ["can't be blank"] })
        
        patch :update, params: { id: category.id, category: invalid_attributes }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:category_to_delete) { create(:category) }

    it "destroys the requested category" do
      expect {
        delete :destroy, params: { id: category_to_delete.id }
      }.to change(Category, :count).by(-1)
    end

    it "redirects to admin categories index" do
      delete :destroy, params: { id: category_to_delete.id }
      expect(response).to redirect_to(admin_categories_path)
      expect(response).to have_http_status(:see_other)
    end

    it "sets a success notice" do
      delete :destroy, params: { id: category_to_delete.id }
      expect(flash[:notice]).to be_present
    end

    context "JSON format" do
      it "returns no content status" do
        delete :destroy, params: { id: category_to_delete.id }, format: :json
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
        expect(response).to redirect_to(new_admin_session_path)
      end

      it "redirects to admin sign in for show" do
        get :show, params: { id: category.id }
        expect(response).to redirect_to(new_admin_session_path)
      end
    end
  end

  describe "private methods" do
    describe "#set_category" do
      it "sets @category for show action" do
        get :show, params: { id: category.id }
        expect(assigns(:category)).to eq(category)
      end
    end

    describe "#category_params" do
      it "permits allowed parameters" do
        params = ActionController::Parameters.new(
          category: {
            name: "Test",
            description: "Test desc",
            image: "test.jpg",
            image_url: "http://example.com/test.jpg",
            forbidden_param: "not allowed"
          }
        )
        
        controller.params = params
        permitted_params = controller.send(:category_params)
        
        expect(permitted_params.permitted?).to be true
        expect(permitted_params.keys).to match_array(%w[name description image image_url])
      end
    end
  end
end