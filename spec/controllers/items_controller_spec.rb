require 'rails_helper'

RSpec.describe ItemsController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }
  let(:list) { FactoryGirl.create(:list, user: user) }
  let(:user2) { FactoryGirl.create(:user) }
  let(:item) { FactoryGirl.create(:item, list: list, user: user) }
  let(:list_w_items) { FactoryGirl.create(:list, :with_items) }

  describe 'item#create' do
    context 'when user logged in' do
      context 'and list belongs to user' do
        it 'creates an item' do
          sign_in list.user
          expect { post :create, params: { list_id: list.id, item: FactoryGirl.attributes_for(:item) } }.to change(Item, :count).by(1)
        end
        it 'redirects to list show page' do
          sign_in list.user
          post :create, params: { list_id: list.id, item: FactoryGirl.attributes_for(:item) }
          expect(response).to redirect_to list_path(list.id)
        end
      end
      context 'but list does NOT belong to user' do
        it 'warns user CANNOT add item' do
          sign_in user2
          post :create, params: { list_id: list.id, item: FactoryGirl.attributes_for(:item) }
          expect(response).to have_http_status(:forbidden)
        end
      end
      context 'but list does NOT exist' do
        it 'returns 404' do
          sign_in user
          post :create, params: { list_id: 'bad_id', item: FactoryGirl.attributes_for(:item) }
          expect(response).to have_http_status(:not_found)
        end
      end
    end
    context 'when user NOT logged in' do
      it 'does NOT add item' do
        expect { post :create, params: { list_id: list.id, item: FactoryGirl.attributes_for(:item) } }.to_not change(Item, :count)
      end
      it 'redirects to sign in page' do
        post :create, params: { list_id: list.id, item: FactoryGirl.attributes_for(:item) }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'item#new' do
    context 'when user is logged in' do
      context 'and list belongs to user' do
        it 'responds success' do
          sign_in list.user
          get :new, params: { list_id: list.id }
          expect(response).to have_http_status(:success)
        end
      end
      context 'and list does NOT belong to user' do
        it 'warns CANNOT add item to list' do
          sign_in user2
          get :new, params: { list_id: list.id }
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
    context 'when user is NOT logged in' do
      it 'redirects to login page' do
        get :new, params: { list_id: list.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'item#edit' do
    context 'when user is logged in' do
      context 'and list belongs to user' do
        it 'redirects to edit page' do
          sign_in list.user
          get :edit, params: { id: item.id, list_id: list.id }
          expect(response).to redirect_to(edit_list_item_path)
        end
      end
      context 'and list does NOT belong to user' do
        it 'warns CANNOT edit item' do
          sign_in user2
          get :edit, params: { id: item.id, list_id: list.id }
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
    context 'when user is NOT logged in' do
      it 'redirects to log in page' do
        get :edit, params: { id: item.id, list_id: list.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'item#update' do
    context 'when user is logged in' do
      context 'and list belongs to user' do
        it 'updates the item' do
          sign_in list_w_items.user
          put :update, params: { id: list_w_items.items.first.id, list_id: list_w_items.id, item: { name: 'changed_item_name' } }
          list_w_items.reload
          expect(list_w_items.items.first.name).to eq('changed_item_name')
        end
      end
      context 'and list does NOT belong to user' do
        it 'warns CANNOT edit item' do
          sign_in user2
          put :update, params: { name: 'changed_item_name', id: item.id, list_id: list.id }
          expect(response).to have_http_status(:forbidden)
        end
        it 'does NOT update item' do
          sign_in user2
          expect { put :update, params: { name: 'changed_item_name', id: item.id, list_id: list.id } }.not_to change(item, :name)
        end
      end
    end
    context 'when user is NOT logged in' do
      it 'redirects to log in page' do
        put :update, params: { name: 'changed_item_name', id: item.id, list_id: list.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'items#show' do
    context 'when user is logged in' do
      it 'shows item detail page' do
        sign_in list_w_items.user
        get :show, params: { list_id: list_w_items.id, id: list_w_items.items.first.id }
        expect(response).to have_http_status(:success)
      end
    end
    context 'when user is NOT logged in' do
      it 'redirects to sign in page' do

      end
    end
    context 'when item does not exist' do
      it 'returns 404 error' do

      end
    end
  end
end
