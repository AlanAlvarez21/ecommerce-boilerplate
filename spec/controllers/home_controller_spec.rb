require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  let!(:categories) { create_list(:category, 5) }
  let!(:products) { create_list(:product, 5) }

  describe "GET #index" do
    before { get :index }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "renders the index template" do
      expect(response).to render_template(:index)
    end

    it "assigns @main_categories with first 4 categories" do
      expect(assigns(:main_categories)).to eq(categories.take(4))
    end

    it "assigns @products with first 4 products" do
      expect(assigns(:products)).to eq(products.take(4))
    end

    it "limits categories to 4" do
      expect(assigns(:main_categories).size).to eq(4)
    end

    it "limits products to 4" do
      expect(assigns(:products).size).to eq(4)
    end
  end
end
