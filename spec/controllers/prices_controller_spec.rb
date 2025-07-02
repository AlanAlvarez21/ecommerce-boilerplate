require 'rails_helper'

RSpec.describe PricesController, type: :controller do
  describe "GET #index" do
    let(:mock_prices) do
      {
        "Oro" => { "compra" => "1500.00", "venta" => "1520.00" },
        "Plata" => { "compra" => "25.50", "venta" => "26.00" }
      }
    end

    before do
      allow(BbvaScraper).to receive(:obtener_precios).and_return(mock_prices)
    end

    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template(:index)
    end

    it "assigns prices from BbvaScraper" do
      get :index
      expect(assigns(:precios)).to eq(mock_prices)
    end

    it "calls BbvaScraper.obtener_precios" do
      expect(BbvaScraper).to receive(:obtener_precios).and_return(mock_prices)
      get :index
    end

    context "when BbvaScraper raises an error" do
      before do
        allow(BbvaScraper).to receive(:obtener_precios).and_raise(StandardError.new("Scraper error"))
      end

      it "lets the error bubble up" do
        expect {
          get :index
        }.to raise_error(StandardError, "Scraper error")
      end
    end

    context "when BbvaScraper returns nil" do
      before do
        allow(BbvaScraper).to receive(:obtener_precios).and_return(nil)
      end

      it "assigns nil to @precios" do
        get :index
        expect(assigns(:precios)).to be_nil
      end
    end

    context "when BbvaScraper returns empty hash" do
      before do
        allow(BbvaScraper).to receive(:obtener_precios).and_return({})
      end

      it "assigns empty hash to @precios" do
        get :index
        expect(assigns(:precios)).to eq({})
      end
    end
  end
end