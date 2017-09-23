class ListsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create destroy update]

  def new
    @list = List.new
  end

  def index
    @lists = List.all
  end

  def create
    @list = List.create(list_params.merge(user: current_user))
    if @list.valid?
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @list = List.find(params[:id])
  end

  def destroy
    byebug
    @list = List.find(params[:id])
    @list.destroy
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
