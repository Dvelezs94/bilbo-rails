class Admin::SalesController < ApplicationController
  access admin: :all
  before_action :get_sale, only: [:show, :edit, :update, :destroy]
  before_action :get_available_boards, only: [:new, :edit]

  def index
    @sales = Sale.all.order(created_at: :desc)
  end

  def new
    @sale = Sale.new
  end

  def create
    @sale = Sale.new(sales_params)
    if @sale.save!
      flash[:success] = "Sale created"
    else
      flash[:error] = "Error creating sale"
    end
    redirect_to admin_sales_path
  end

  def show
  end

  def edit
  end

  def update
    if @sale.update!(sales_params)
      flash[:success] = "Sale was successfully updated"
    else
      flash[:error] = "Error updating sale"
    end
    redirect_to admin_sales_path
  end

  def destroy
    if @sale.destroy!
      flash[:success] = "Sale removed"
    else
      flash[:error] = "Error removing sale"
    end
    redirect_to admin_sales_path
  end

  private

  def sales_params
    params.require(:sale).permit(:description, :percent,
                                 :starts_at, :ends_at,
                                  board_ids: [])
  end

  def get_available_boards
    @boards = Board.enabled
  end

  def get_sale
    @sale = Sale.find(params[:id])
  end
end
