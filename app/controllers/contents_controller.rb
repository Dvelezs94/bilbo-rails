class ContentsController < ApplicationController
  access user: :all, provider: :all
  before_action :get_content, only: [:destroy]

  def index
    @contents = @project.contents
  end

  def create
  end

  private

  def get_content
    @ad = @project.contents.friendly.find(params[:id])
  end
end
