class SearchesController < ApplicationController
  def autocomplete_user_email
    term = params[:term]
    users = User.where("email LIKE '%#{term}%' AND roles= 'provider'")
    render :json => users.map { |user| {:id => user.id, :label => user.email, :value => user.email} }
  end
end
