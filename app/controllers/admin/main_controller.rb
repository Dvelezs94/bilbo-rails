class Admin::MainController < ApplicationController
  access admin: :all

  def index
  end

  def new
  end

  def show
  end

  def create
  end

  def display_autocomplete
    "#{self.email}.camelize"
  end

end
