require 'rails_helper'

RSpec.describe ItemsController, type: :controller do
  let(:list) { FactoryGirl.create(:list) }
  let(:user) { FactoryGirl.create(:user) }
  let(:item) { FactoryGirl.create(:item) }

  describe 'item#create' do
    context 'when user logged in' do
      context 'list belongs to user' do
        it 'creates an item' do
          sign_in list.user
          expect { post :create, params: { list_id: list.id, item: FactoryGirl.attributes_for(:item) } }.to change(Item, :count).by(1)
        end
        it 'redirects to list show page' do
          sign_in list.user
          post :create, params: { list_id: list.id, item: FactoryGirl.attributes_for(:item) }
          expect(response).to redirect_to(list_url(item.list))
        end
      end
      context 'list does NOT belong to user' do
        let(:user2) { FactoryGirl.create(:user2) }
        it 'warns user CANNOT add item' do
          sign_in user2
          post :create, params: { list_id: list.id, item: FactoryGirl.attributes_for(:item) }
          expect(response).to have_http_status(:forbidden)
        end
      end
      context 'list does NOT exist' do
        it 'returns 404' do
          sign_in user
          post :create, params: { list_id: 'bad_id', item: FactoryGirl.attributes_for(:item) }
          expect(response).to have_http_status(:not_found)
        end
      end
    end
    context 'user NOT logged in' do
      it 'does NOT add item' do
        expect { post :create, params: { list_id: list.id, item: FactoryGirl.attributes_for(:item) } }.to_not change(Item, :count)
      end
      it 'redirects to sign in page' do
        post :create, params: { list_id: list.id, item: FactoryGirl.attributes_for(:item) }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
