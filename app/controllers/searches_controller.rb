class SearchesController < ApplicationController
  autocomplete :user, :email, :extra_data => [:roles], :full => true
end
