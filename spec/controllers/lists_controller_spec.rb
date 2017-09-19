require 'rails_helper'

RSpec.describe ListsController, type: :controller do
  describe 'lists#index' do
    it 'shows lists index page' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
  describe 'lists#new' do
    it 'shows new form for list' do
      get :new
      expect(response).to have_http_status(:success)
    end
  end
  describe 'lists#create' do
    let!(:list) { FactoryGirl.create(:list) }
    it 'directs user to root' do
      post :create, params: { list: FactoryGirl.attributes_for(:list) }
      expect(response).to redirect_to(root_path)
    end
    it 'creates list' do
      last_list = List.last
      expect(last_list.name).to eq('list_name')
      expect(last_list.date).to eq(Time.zone.today)
    end
  end
end
