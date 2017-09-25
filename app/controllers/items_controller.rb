class ItemsController < ApplicationController
  before_action :authenticate_user!, only: [:create]
  def create

  end

  private

  def current_list
    if params[:list_id]
      @current_list ||= List.find(params[:list_id])
    else
      current_item.list
    end
  end

  def current_item
    @current_item ||= Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name)
  end
end
