require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: "Hello #{I18n.locale}"
    end
  end

  describe "locale handling" do
    context "when locale parameter is provided" do
      it "sets the locale from params" do
        get :index, params: { locale: :es }
        expect(I18n.locale).to eq(:es)
      end

      it "renders with the set locale" do
        get :index, params: { locale: :es }
        expect(response.body).to eq("Hello es")
      end
    end

    context "when no locale parameter is provided" do
      it "uses the default locale" do
        I18n.default_locale = :en
        get :index
        expect(I18n.locale).to eq(:en)
      end
    end
  end

  describe "#default_url_options" do
    it "includes the current locale" do
      I18n.locale = :es
      expect(controller.send(:default_url_options)).to eq({ locale: :es })
    end
  end

  describe "before_action :set_locale" do
    it "calls set_locale before each action" do
      expect(controller).to receive(:set_locale).and_call_original
      get :index
    end
  end
end
