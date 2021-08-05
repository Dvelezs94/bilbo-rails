class SearchesController < ApplicationController
  # autocompletes email for when creating a bilbo on the admin
  def autocomplete_user_email
    term = params[:term]
    users = User.where("email LIKE '%#{term}%' AND roles= 'provider'")
    render :json => users.map { |user| {:id => user.projects.first.id, :label => user.email, :value => user.email} }
  end

  def autocomplete_board_name
    term = params[:term]
    if @project.dashboard_player.present?
     boards = @project.boards.where.not(id: [@project.dashboard_player.board_dashboard_players.map{|player| player.board_id}]).where("name LIKE '%#{term}%'")  
    else
     boards = @project.boards.where("name LIKE '%#{term}%'")
    end
    render :json => boards.map { |board| {:id => board.slug, :label => board.name, :value => board.name} }
  end

  # autocompletes user when checking users on admin
  # def autocomplete_user_admin
  #   term = params[:term]
  #   users = User.where("email LIKE '%#{term}%'")
  #   render :json => users.map { |user| {:id => user.id, :label => user.email, :value => user.email} }
  # end
end
