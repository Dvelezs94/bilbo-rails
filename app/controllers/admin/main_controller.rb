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

  def web_console
    if !Rails.env.production?
      console
      render inline: '<h2>console page</h2>'
    else
      render inline: '<h2>This is not enabled in production</h2>'
    end
  end

  def display_autocomplete
    "#{self.email}.camelize"
  end

end
