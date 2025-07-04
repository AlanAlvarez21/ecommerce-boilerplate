require 'rails_helper'

RSpec.describe CategoriesController, type: :controller do
  let(:category) { create(:category) }
  let!(:products) { create_list(:product, 3, category: category) }

  describe "GET #show" do
    context "with valid category id" do
      it "returns http success" do
        get :show, params: { id: category.id }
        expect(response).to have_http_status(:success)
      end

      it "renders the show template" do
        get :show, params: { id: category.id }
        expect(response).to render_template(:show)
      end

      it "assigns the requested category" do
        get :show, params: { id: category.id }
        expect(assigns(:category)).to eq(category)
      end

      it "assigns products belonging to the category" do
        get :show, params: { id: category.id }
        expect(assigns(:products)).to match_array(products)
      end
    end

    context "with invalid category id" do
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

    context "when category has no products" do
      let(:empty_category) { create(:category) }

      it "assigns empty products collection" do
        get :show, params: { id: empty_category.id }
        expect(assigns(:products)).to be_empty
      end
    end
  end
end
