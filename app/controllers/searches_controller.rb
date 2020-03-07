class SearchesController < ApplicationController
  autocomplete :user, :email, :full => true
end
