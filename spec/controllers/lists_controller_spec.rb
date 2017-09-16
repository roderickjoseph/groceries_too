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
    it 'creates new list and directs user to root' do
      post :create, params: { list: { name: 'first_name', date: Date.new(2017, 9, 16) } }
      expect(response).to redirect_to(root_path)

      list = List.last
      expect(list.name).to eq('first_name')
      expect(list).to eq('2017-09-16')
    end
  end
end
