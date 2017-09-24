class ListsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create destroy update]

  def new
    @list = List.new
  end

  def index
    @lists = List.all
  end

  def show
    @list = List.find_by(id: params[:id])
    render plain: 'No list found', status: :not_found if @list.blank?
  end

  def create
    @list = current_user.lists.create(list_params)
    if @list.valid?
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @list = List.find_by(id: params[:id])
    return render :not_found if @list.blank?
    return render :forbidden unless @list.user == current_user
  end

  def update
    @list = List.find_by(id: params[:id])

    if @list.blank?
      flash[:alert] = 'List  not found'
      return render :index, status: :not_found
    elsif current_user != @list.user
      flash[:alert] = 'Cannot modify this list'
      return render :show, status: :forbidden
    else
      @list.update(list_params)
      unless @list.valid?
        flash[:alert] = 'Name cannot be empty'
        return render :edit, status: :unprocessable_entity
      end
    end
    redirect_to root_path
  end

  def destroy
    @list = List.find_by(id: params[:id])

    if @list.blank?
      flash[:alert] = 'List not found'
      return render :index, status: :not_found
    elsif current_user != @list.user
      flash[:alert] = 'Cannot delete list'
      return render :show, status: :forbidden
    else
      @list.destroy
      redirect_to root_path
    end
  end

  private

  def list_params
    params.require(:list).permit(:name, :date)
  end
end
