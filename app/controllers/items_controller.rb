class ItemsController < ApplicationController
  before_action :authenticate_user!, only: [:create]

  def new
    current_list = List.find_by(id: params[:list_id])
    if !current_user
      flash[:alert] = 'You must log in to add item'
      redirect_to(new_user_session_path)
    elsif current_user != current_list.user
      flash[:alert] = "Cannot add item to another's list"
      render 'lists/show', status: :forbidden
    else
      @item = Item.new
    end
  end

  def edit
    current_list = List.find_by(id: params[:list_id])
    if !current_user
      flash[:alert] = 'You must log in to edit an item'
      redirect_to(new_user_session_path)
    elsif current_user != current_list.user
      flash[:alert] = "Cannot edit item of another's list"
      render 'lists/show', status: :forbidden
    else
      redirect_to(edit_list_item_path)
    end
  end

  def create
    if current_list.blank?
      flash[:alert] = 'Cannot create item for unknown list'
      render 'lists/index', status: :not_found
    elsif current_user != current_list.user
      flash[:alert] = "Cannot add item to somebody else's list"
      render 'lists/show', status: :forbidden
    else
      current_list.items.create(item_params.merge(user: current_user))
      redirect_to list_path(current_list.id)
    end
  end

  def update
    @item = current_list.items.find_by(id: params[:id])

    return redirect_to(new_user_session_path) unless current_user

    if current_list.blank?
      flash[:alert] = 'List not found'
      return render :index, status: :not_found
    elsif @item.blank?
      flash[:alert] = 'Item not found'
      return render 'lists/show', status: :not_found
    elsif current_user != current_list.user
      flash[:alert] = 'Cannot modify this list'
      return render 'lists/show', status: :forbidden
    else
      @item.update(item_params)
      unless @item.valid?
        flash[:alert] = 'Name cannot be empty'
        return render :edit, status: :unprocessable_entity
      end
    end
    redirect_to list_path(current_list.id)
  end

  private

  def current_list
    @current_list ||= List.find_by(id: params[:list_id])
  end

  def item_params
    params.require(:item).permit(:name)
  end
end
