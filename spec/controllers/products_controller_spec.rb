require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  let(:product) { create(:product) }

  describe "GET #show" do
    context "with valid product id" do
      it "returns http success" do
        get :show, params: { id: product.id }
        expect(response).to have_http_status(:success)
      end

      it "renders the show template" do
        get :show, params: { id: product.id }
        expect(response).to render_template(:show)
      end

      it "assigns the requested product" do
        get :show, params: { id: product.id }
        expect(assigns(:product)).to eq(product)
      end
    end

    context "with invalid product id" do
      it "raises ActiveRecord::RecordNotFound" do
        expect {
          get :show, params: { id: 'invalid' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "raises ActiveRecord::RecordNotFound for non-existent id" do
        expect {
          get :show, params: { id: 99999 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end