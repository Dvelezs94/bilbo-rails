class ImpressionsController < ApplicationController
  access provider: :all
  before_action :validate_provider
  before_action :get_boards, only: :index

  def index
  end

  def show
  end

  def fetch
    get_board_impressions
    respond_to do |format|
        format.js
    end
  end

  def get_boards
    @boards = @project.boards
  end

  # here we get all the impressions
  def get_board_impressions
    @campaign_impressions = {}
    @impressions = Board.find(impression_params[:board_id]).impressions.where(created_at: impression_params[:start_date]..impression_params[:end_date])
    @impressions.group(:campaign_id).count.each do |key, value|
      @campaign_impressions[key] = {impressions_count: value, total_invested: @impressions.group(:campaign_id).sum(:total_price)[key]}
    end
    @start_date = impression_params[:start_date]
    @end_date = impression_params[:end_date]
    @board_impression = impression_params[:board_id]
    return @campaign_impressions
  end

  # make sure only the correct provider can access the impressions
  def validate_provider
    true
  end

  def impression_params
    @impression_params = params.require(:impression).permit(:board_id, :start_date, :end_date)
    # format time received from the request so we can use it
    @impression_params[:start_date] = Date.strptime(@impression_params[:start_date], '%m-%d-%Y')
    @impression_params[:end_date] = Date.strptime(@impression_params[:end_date], '%m-%d-%Y')
    @impression_params
  end
end
