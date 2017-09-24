require 'rails_helper'

RSpec.describe ListsController, type: :controller do
  let!(:list) { FactoryGirl.create(:list) }
  let(:user) { FactoryGirl.create(:user) }

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
    context 'user logged in' do
      it 'directs user to root' do
        sign_in user
        post :create, params: { list: FactoryGirl.attributes_for(:list) }
        expect(response).to redirect_to(root_path)
      end
      it 'creates list' do
        sign_in user
        post :create, params: { list: FactoryGirl.attributes_for(:list) }
        expect(List.last.name).to eq('list_name')
      end
    end
    context 'user NOT logged in' do
      it 'directs user to sign in page' do
        post :create, params: { list: FactoryGirl.attributes_for(:list) }
        expect(response).to redirect_to(new_user_session_path)
      end
      it 'does NOT create a list' do
        list_count = List.count
        post :create, params: { list: FactoryGirl.attributes_for(:list) }
        expect(List.count).to eq(list_count)
      end
    end
    context 'missing list name' do
      it 'asks for valid name and does NOT create a list' do
        sign_in user
        list_count = List.count
        post :create, params: { list: { name: '', date: Time.zone.today } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(List.count).to eq(list_count)
      end
    end
  end
  describe 'lists#show' do
    it 'shows the specified list page' do
      get :show, params: { id: list.id }
      expect(response).to have_http_status(:success)
    end
  end
  describe 'lists#destroy' do
    context 'user logged in' do
      it 'deletes list' do
        sign_in list.user
        delete :destroy, params: { id: list.id }
        expect(response).to redirect_to(root_path)
      end
      it 'returns 404 if specified list does not exist' do
        sign_in user
        delete :destroy, params: { id: 'bad_id' }
        expect(response).to have_http_status(:not_found)
      end
    end
    context "list is NOT the logged in user's list" do
      let(:user2) { FactoryGirl.create(:user2) }
      it 'warns user: not their list' do
        sign_in user2
        delete :destroy, params: { id: list.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
  describe 'lists#update' do
    it 'updates the list' do
      sign_in list.user
      put :update, params: { id: list.id, list: { name: 'changed_name', date: Time.zone.today } }
      list.reload
      expect(list.name).to eq('changed_name')
    end
  end
end
