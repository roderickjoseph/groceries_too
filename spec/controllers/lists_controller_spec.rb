require 'rails_helper'

RSpec.describe ListsController, type: :controller do
  let(:list) { FactoryGirl.create(:list) }
  let(:user) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }

  describe 'lists#index' do
    it 'shows lists index page' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'lists#show' do
    context 'when list exists' do
      it 'shows the specified list page' do
        get :show, params: { id: list.id }
        expect(response).to have_http_status(:success)
      end
    end
    context 'when list does NOT exist' do
      it 'returns 404 not found' do
        get :show, params: { id: 'bad_id' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'lists#new' do
    context 'when user is logged in' do
      it 'responds success' do
        sign_in user
        get :new
        expect(response).to have_http_status(:success)
      end
    end
    context 'when user is NOT logged in' do
      it 'redirects to login page' do
        get :new
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'lists#edit' do
    context 'user is logged in' do
      context 'and list belongs to user' do
        it 'redirects to edit page' do
          sign_in list.user
          get :edit, params: { id: list.id }
          expect(response).to have_http_status(:success)
        end
      end
      context 'and list does NOT belong to user' do
        it 'warns user CANNOT edit list' do
          sign_in user2
          get :edit, params: { id: list.id }
          expect(response).to have_http_status(:forbidden)
        end
      end
      context 'but list does NOT exist' do
        it 'returns 404 if list is not found' do
          sign_in user
          get :edit, params: { id: 'bad_id' }
          expect(response).to have_http_status(:not_found)
        end
      end
    end
    context 'user is NOT logged in' do
      it 'directs user to sign in page' do
        get :edit, params: { id: list.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'lists#create' do
    context 'when user logged in' do
      it 'directs user to root' do
        sign_in user
        post :create, params: { list: FactoryGirl.attributes_for(:list) }
        expect(response).to redirect_to(root_path)
      end
      it 'creates list' do
        sign_in user
        expect { post :create, params: { list: FactoryGirl.attributes_for(:list) } }.to change(List, :count).by(1)
      end
    end
    context 'when user NOT logged in' do
      it 'directs user to sign in page' do
        post :create, params: { list: FactoryGirl.attributes_for(:list) }
        expect(response).to redirect_to(new_user_session_path)
      end
      it 'does NOT create a list' do
        expect { post :create, params: { list: FactoryGirl.attributes_for(:list) } }.to_not change(List, :count)
      end
    end
    context 'when missing list name' do
      it 'asks for valid name' do
        sign_in user
        post :create, params: { list: { name: '', date: Time.zone.today } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
      it 'does NOT create a list' do
        sign_in user
        expect { post :create, params: { list: { name: '', date: Time.zone.today } } }.to_not change(List, :count)
      end
    end
  end

  describe 'lists#update' do
    context 'when user logged in' do
      context 'and list belongs to user' do
        it 'redirects to root' do
          sign_in list.user
          put :update, params: { id: list.id, list: { name: 'changed_name', date: Time.zone.today } }
          expect(response).to redirect_to(root_path)
        end
        it 'updates the list' do
          sign_in list.user
          put :update, params: { id: list.id, list: { name: 'changed_name', date: Time.zone.today } }
          list.reload
          expect(list.name).to eq('changed_name')
        end
      end
      context 'and list does NOT belong to user' do
        it 'does not update list' do
          sign_in user2
          expect { put :update, params: { id: list.id, list: { name: 'changed_name', date: Time.zone.today } } }.to_not change(list, :name)
        end
        it 'warns user CANNOT update list' do
          sign_in user2
          put :update, params: { id: list.id, list: { name: 'changed_name', date: Time.zone.today } }
          expect(response).to have_http_status(:forbidden)
        end
      end
      context 'but list CANNOT be found' do
        it 'returns 404' do
          sign_in list.user
          put :update, params: { id: 'bad_id' }
          expect(response).to have_http_status(:not_found)
        end
      end
    end
    context 'when user is NOT logged in' do
      it 'does not update list' do
        expect { put :update, params: { id: list.id, list: { name: 'changed_name', date: Time.zone.today } } }.to_not change(list, :name)
      end
      it 'redirects to sign in page' do
        put :update, params: { id: list.id, list: { name: 'changed_name', date: Time.zone.today } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'lists#destroy' do
    context 'when user logged in' do
      context 'and list belongs to user' do
        it 'directs to root' do
          sign_in list.user
          delete :destroy, params: { id: list.id }
          expect(response).to redirect_to(root_path)
        end
        it 'deletes list' do
          sign_in list.user
          expect { delete :destroy, params: { id: list.id } }.to change(List, :count).by(-1)
        end
      end
      context 'but list is not found' do
        it 'returns 404' do
          sign_in user
          delete :destroy, params: { id: 'bad_id' }
          expect(response).to have_http_status(:not_found)
        end
      end
      context 'and list does NOT belong to user' do
        it 'warns they CANNOT delete list' do
          sign_in user2
          delete :destroy, params: { id: list.id }
          expect(response).to have_http_status(:forbidden)
        end
        it 'does NOT delete list' do
          sign_in user2
          delete :destroy, params: { id: list.id }
          expect { delete :destroy, params: { id: list.id } }.to_not change(List, :count)
        end
      end
    end
    context 'when user is NOT logged in' do
      it 'redirects to sign in page' do
        delete :destroy, params: { id: list.id }
        expect(response).to redirect_to(new_user_session_path)
      end
      it 'does NOT delete list' do
        delete :destroy, params: { id: list.id }
        expect { delete :destroy, params: { id: list.id } }.to_not change(List, :count)
      end
    end
  end
end
