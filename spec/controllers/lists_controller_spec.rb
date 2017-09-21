require 'rails_helper'

RSpec.describe ListsController, type: :controller do
  let!(:list) { FactoryGirl.create(:list) }
  let!(:user) { FactoryGirl.create(:user) }

  describe 'lists#index' do
    it 'shows lists index page' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
  describe 'lists#new' do
    context 'user is logged in' do
      it 'responds success' do
        sign_in user
        get :new
        expect(response).to have_http_status(:success)
      end
    end
    context 'user is NOT logged in' do
      it 'redirects to login page' do
        get :new
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
  describe 'lists#create' do
    it 'directs user to root' do
      sign_in user
      post :create, params: { list: FactoryGirl.attributes_for(:list) }
      expect(response).to redirect_to(root_path)
    end
    it 'creates list' do
      last_list = List.last
      expect(last_list.name).to eq('list_name')
      expect(last_list.date).to eq(Time.zone.today)
    end
  end
  describe 'lists#show' do
    it 'shows the specified list page' do
      get :show, params: { id: list.id }
      expect(response).to have_http_status(:success)
    end
  end
  describe 'lists#destroy' do
    it 'deletes list' do
      delete :destroy, params: { id: list.id }
      expect { List.find(list.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
  describe 'lists#update' do
    it 'updates the list' do
      put :update, params: { id: list.id, list: { name: 'changed_name', date: Time.zone.today } }
      list.reload
      expect(list.name).to eq('changed_name')
    end
  end
end
