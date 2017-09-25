class ItemsController < ApplicationController
  before_action :authenticate_user!, only: [:create]
  def create
    @item = current_user.lists.items.create(item_params)
  end

  private

  def item_params
    params.require(:item).permit(:name)
  end
end
