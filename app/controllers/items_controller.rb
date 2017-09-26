class ItemsController < ApplicationController
  before_action :authenticate_user!, only: [:create]

  def new
    @list = List.find_by(id: params[:list_id])
    if !current_user
      flash[:alert] = 'You must log in to add item'
      redirect_to(new_user_session_path)
    elsif current_user != @list.user
      flash[:alert] = "Cannot add item to another's list"
      render 'lists/show', status: :forbidden
    else
      @item = Item.new
    end
  end

  def create
    @list = List.find_by(id: params[:list_id])

    if @list.blank?
      flash[:alert] = 'Cannot create item for unknown list'
      return render 'lists/index', status: :not_found
    elsif current_user != @list.user
      flash[:alert] = "Cannot add item to somebody else's list"
      return render 'lists/show', status: :forbidden
    else
      @list.items.create(item_params.merge(user: current_user))
      redirect_to list_path(@list.id)
    end
  end

  private

  def current_list
    if params[:list_id]
      @current_list ||= List.find(params[:list_id])
    else
      current_item.list
    end
  end

  def item_params
    params.require(:item).permit(:name)
  end
end
