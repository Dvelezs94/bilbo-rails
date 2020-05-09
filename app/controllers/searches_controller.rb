class SearchesController < ApplicationController
  # autocompletes email for when creating a bilbo on the admin
  def autocomplete_user_email
    term = params[:term]
    users = User.where("email LIKE '%#{term}%' AND roles= 'provider'")
    render :json => users.map { |user| {:id => user.id, :label => user.email, :value => user.email} }
  end

  # autocompletes user when checking users on admin
  # def autocomplete_user_admin
  #   term = params[:term]
  #   users = User.where("email LIKE '%#{term}%'")
  #   render :json => users.map { |user| {:id => user.id, :label => user.email, :value => user.email} }
  # end
end
