class ContentsController < ApplicationController
  access user: :all, provider: :all
  before_action :get_content, only: [:update, :destroy]

  def index
    @contents = @project.contents
  end

  def new_multimedia
    @content = Content.new
  end

  def new_url
  end

  def update
    if @content.update(content_params)
      flash[:success] = "Success"
    end
  end

  def create
    @content = @project.contents.create(content_params)
    @content.multimedia_derivatives!
    if ! @content.save
      flash[:error] = "Error"
    else
      flash[:success] = "Success"
    end
    redirect_to contents_path
  end

  def destroy
    @content.destroy
    redirect_to contents_path
  end

  private

  def get_content
    @content = @project.contents.find(params[:id])
  end

  def content_params
    params.require(:content).permit(:url, :multimedia, :duration).merge(:project_id => @project.id)
  end
end
