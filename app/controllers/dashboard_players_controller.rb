class DashboardPlayersController < ApplicationController
  before_action :verify_identity
  before_action :verify_not_exist_board_on_player, only: [:create]
  access all: [:index, :show, :new, :edit, :create, :update, :destroy], user: :all
  autocomplete :board, :name
  def index
    if @project.dashboard_player.present?
      @dashboard_players = @project.dashboard_player.board_dashboard_players
    end
  end

  def create
    if @project.dashboard_player.nil?
       @dashboard_player = DashboardPlayer.create(dashboard_player_params)
      if @dashboard_player.save
        if @dashboard_player_board = @dashboard_player.board_dashboard_players.where(board_id: Board.friendly.find(dashboard_player_params[:board_slug]).id).first_or_create
          @success_message = I18n.t("ads.transitions.update.success")
          @player= @project.dashboard_player
        else
          @error_message = I18n.t("ads.transitions.update.error")
        end
      end
    else
      if @dashboard_player_board = @project.dashboard_player.board_dashboard_players.where(board_id: Board.friendly.find(dashboard_player_params[:board_slug]).id).first_or_create
        @success_message = I18n.t("ads.transitions.update.success")
      else
        @error_message = I18n.t("ads.transitions.update.error")
      end
    end
    render 'dashboard_players/add_player'
  end

  def delete_player
    @board = Board.friendly.find(params[:board_id_dashboard_player])
    if @project.dashboard_player.board_dashboard_players.find_by(board_id: @board.id).destroy
      @success_message = I18n.t("ads.transitions.update.success")
    else 
      @error_message = I18n.t("ads.transitions.update.error")
    end
  end

  private
    def verify_identity
      raise_not_found if not @project.users.pluck(:id).include? current_user.id
    end

    def verify_not_exist_board_on_player
      if @project.dashboard_player.present?
        @project.dashboard_player.board_dashboard_players.map{|player| p player.board.slug}
        if @project.dashboard_player.board_dashboard_players.map{|player| player.board.slug}.include? dashboard_player_params[:board_slug].to_s
          @error_message = I18n.t("ads.transitions.update.error")
          render 'dashboard_players/message'
        end
      end
    end

    def dashboard_player_params
      params.require(:dashboard_player).permit(:board_slug, :project_id)
    end 
end
