class ListsController < ApplicationController

  def new
    @list = List.new
  end

  def index
  end

  def create
    @list = List.create(list_params)
    redirect_to root_path
  end

  private

  def list_params
    params.require(:list).permit(:name)
  end
end
