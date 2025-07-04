require 'rails_helper'

RSpec.describe Admin::RegistrationsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
  end

  describe "parameter sanitization" do
    describe "#configure_sign_up_params" do
      let(:valid_params) do
        {
          admin: {
            email: "test@example.com",
            password: "password123",
            password_confirmation: "password123",
            name: "Admin User",
            address: "123 Main St"
          }
        }
      end

      it "permits name and address for sign up" do
        post :create, params: valid_params
        
        # Verify the admin was created with the correct attributes
        admin = Admin.last
        expect(admin.name).to eq("Admin User")
        expect(admin.address).to eq("123 Main St")
      end

      it "calls configure_sign_up_params before create" do
        expect(controller).to receive(:configure_sign_up_params).and_call_original
        
        post :create, params: valid_params
      end
    end

    describe "#configure_account_update_params" do
      let(:admin) { create(:admin) }
      let(:update_params) do
        {
          admin: {
            email: "updated@example.com",
            name: "Updated Name",
            address: "456 Oak St",
            current_password: "password123"
          }
        }
      end

      before do
        sign_in admin
      end

      it "permits name and address for account update" do
        sign_in admin
        patch :update, params: update_params
        
        # Verify the admin was updated with the correct attributes
        admin.reload
        expect(admin.name).to eq("Updated Name")
        expect(admin.address).to eq("456 Oak St")
      end

      it "calls configure_account_update_params before update" do
        expect(controller).to receive(:configure_account_update_params).and_call_original
        
        patch :update, params: update_params
      end
    end
  end

  describe "inheritance from Devise::RegistrationsController" do
    it "inherits from Devise::RegistrationsController" do
      expect(described_class.superclass).to eq(Devise::RegistrationsController)
    end

    it "uses admin devise mapping" do
      get :new
      expect(controller.send(:devise_mapping).name).to eq(:admin)
    end
  end

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end

    it "assigns a new admin" do
      get :new
      expect(assigns(:admin)).to be_a_new(Admin)
    end
  end

  describe "POST #create" do
    let(:valid_attributes) do
      {
        email: "newadmin@example.com",
        password: "password123",
        password_confirmation: "password123",
        name: "New Admin",
        address: "789 Pine St"
      }
    end

    let(:invalid_attributes) do
      {
        email: "",
        password: "short",
        password_confirmation: "different"
      }
    end

    context "with valid parameters" do
      it "creates a new admin" do
        expect {
          post :create, params: { admin: valid_attributes }
        }.to change(Admin, :count).by(1)
      end

      it "redirects to admin root after successful creation" do
        post :create, params: { admin: valid_attributes }
        expect(response).to redirect_to(admin_root_path)
      end

      it "signs in the new admin" do
        post :create, params: { admin: valid_attributes }
        expect(controller.current_admin).to be_present
      end
    end

    context "with invalid parameters" do
      it "does not create a new admin" do
        expect {
          post :create, params: { admin: invalid_attributes }
        }.not_to change(Admin, :count)
      end

      it "renders the new template" do
        post :create, params: { admin: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end

  describe "GET #edit" do
    let(:admin) { create(:admin) }

    before do
      sign_in admin
    end

    it "returns http success" do
      get :edit
      expect(response).to have_http_status(:success)
    end

    it "assigns the current admin" do
      get :edit
      expect(assigns(:admin)).to eq(admin)
    end
  end

  describe "PATCH #update" do
    let(:admin) { create(:admin, name: "Original Name", address: "Original Address") }
    let(:new_attributes) do
      {
        email: "updated@example.com",
        name: "Updated Name",
        address: "Updated Address",
        current_password: "password123"
      }
    end

    before do
      sign_in admin
    end

    context "with valid parameters" do
      it "updates the admin" do
        patch :update, params: { admin: new_attributes }
        admin.reload
        expect(admin.email).to eq("updated@example.com")
        expect(admin.name).to eq("Updated Name")
        expect(admin.address).to eq("Updated Address")
      end

      it "redirects after successful update" do
        patch :update, params: { admin: new_attributes }
        expect(response).to have_http_status(:redirect)
        expect(flash[:notice]).to be_present
      end
    end

    context "with invalid current password" do
      let(:invalid_attributes) do
        {
          email: "updated@example.com",
          current_password: "wrong_password"
        }
      end

      it "does not update the admin" do
        original_email = admin.email
        patch :update, params: { admin: invalid_attributes }
        admin.reload
        expect(admin.email).to eq(original_email)
      end

      it "renders the edit template with errors" do
        patch :update, params: { admin: invalid_attributes }
        expect(response).to render_template(:edit)
        expect(assigns(:admin).errors).to be_present
      end
    end
  end

  describe "authentication" do
    context "when admin is not signed in" do
      it "redirects to sign in for edit" do
        get :edit
        expect(response.location).to include("/admins/sign_in")
      end

      it "redirects to sign in for update" do
        patch :update, params: { admin: { email: "test@example.com" } }
        expect(response.location).to include("/admins/sign_in")
      end
    end
  end
end