class ListsController < ApplicationController

  def new
    redirect_to new_user_session_path unless user_signed_in?
    @list = List.new
  end

  def index
    @lists = List.all
  end

  def create
    redirect_to new_user_session_path && return unless user_signed_in?
    @list = List.create(list_params)
    redirect_to root_path
  end

  def show
    @list = List.find(params[:id])
  end

  def destroy
    @list = List.find(params[:id])
    List.destroy(@list.id)
    redirect_to root_path
  end

  def update
    @list = List.find(params[:id])
    # byebug
    @list.update(list_params)
  end

  private

  def list_params
    params.require(:list).permit(:name, :date)
  end
end
