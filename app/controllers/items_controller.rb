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

  def edit
    @list = List.find_by(id: params[:list_id])
    if !current_user
      flash[:alert] = 'You must log in to edit an item'
      redirect_to(new_user_session_path)
    elsif current_user != @list.user
      flash[:alert] = "Cannot edit item of another's list"
      render 'lists/show', status: :forbidden
    else
      redirect_to(edit_list_item_path)
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

  def update
    # byebug
    @list = List.find_by(id: params[:list_id])
    @item = @list.items.find_by(id: params[:id])
    return redirect_to(new_user_session_path) unless current_user

    if @list.blank?
      flash[:alert] = 'List not found'
      return render :index, status: :not_found
    elsif @item.blank?
      flash[:alert] = 'Item not found'
      return render 'lists/show', status: :not_found
    elsif current_user != @list.user
      flash[:alert] = 'Cannot modify this list'
      return render 'lists/show', status: :forbidden
    else
      @list.items.update(item_params)
      unless @list.valid?
        flash[:alert] = 'Name cannot be empty'
        return render :edit, status: :unprocessable_entity
      end
    end
    redirect_to list_path(@list.id)
  end

  private

  def item_params
    params.require(:item).permit(:name)
  end
end
