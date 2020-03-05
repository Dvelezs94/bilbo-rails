class CsvController < ApplicationController
  access provider: :all

  def provider_boards
    respond_to do |format|
      format.html
      format.csv { send_data current_user.boards.to_csv(["name", "status", "address", "category", "base_earnings", "face", "created_at"]), filename: "bilbos-#{Date.today}.csv" }
    end
  end

  def total_impressions
    @user = current_user.daily_provider_board_impressions(10.years.ago..Time.now)
    respond_to do |format|
      format.html
      format.csv { send_data @user.to_csv(["campaign", "board", "created_at", "total_price"]), filename: "impressions-#{Date.today}.csv" }
    end
  end
end
