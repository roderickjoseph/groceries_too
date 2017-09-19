class ListsController < ApplicationController
  def new
    @list = List.new
  end

  def index
    @lists = List.all
  end

  def create
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

  private

  def list_params
    params.require(:list).permit(:name, :date)
  end
end
