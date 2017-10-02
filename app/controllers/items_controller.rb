class ItemsController < ApplicationController
  before_action :authenticate_user!, only: %i[new edit update destroy create]

  def new
    if current_user != current_list.user
      flash[:alert] = "Cannot add item to another's list"
      render 'lists/show', status: :forbidden
    else
      @item = Item.new
    end
  end

  def show
    @item = current_item

    render 'lists/show', status: :not_found if @item.blank?
  end

  def edit
    return redirect_to(new_user_session_path) unless current_user

    if current_user != current_item.user
      flash[:alert] = "Cannot edit item of another's list"
      render 'lists/show', status: :forbidden
    else
      @item = current_item
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
    @item = current_item

    return redirect_to(new_user_session_path) unless current_user

    if current_item.blank?
      flash[:alert] = 'List not found'
      return render :index, status: :not_found
    elsif @item.blank?
      flash[:alert] = 'Item not found'
      return render 'lists/show', status: :not_found
    elsif current_user != current_item.user
      flash[:alert] = 'Cannot modify this list'
      return render 'lists/show', status: :forbidden
    else
      @item.update(item_params)
      unless @item.valid?
        flash[:alert] = 'Name cannot be empty'
        return render :edit, status: :unprocessable_entity
      end
    end
    redirect_to list_path(current_item.list_id)
  end

  def destroy
    @item = current_item

    if @item.blank?
      flash[:alert] = 'Item not found'
      return render 'lists/show', status: :not_found
    elsif current_user != current_item.user
      flash[:alert] = 'Cannot delete items from this list'
      return render 'lists/show', status: :not_found
    else
      @item.destroy
      redirect_to list_path(current_item.list_id)
    end
  end

  private

  def current_list
    @current_list ||= List.find_by(id: params[:list_id])
  end

  def current_item
    @current_item ||= Item.find_by(id: params[:id])
  end

  def item_params
    params.require(:item).permit(:name)
  end
end
