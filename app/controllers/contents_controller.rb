class ContentsController < ApplicationController
  access user: :all, provider: :all
  before_action :get_content, only: [:update, :destroy]

  def index
    @contents = @project.contents
  end

  def new_multimedia
    @content = Content.new
    @content_modal = params[:content_modal]
    if params[:content_modal].present?
      render  'new_multimedia', :locals => {:content_modal => @content_modal}
    end
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
    if !@content.save
        flash[:error] = "Error"
        redirect_to contents_path
      else
        flash[:success] = "Success"
        if params[:content_modal].present?
          @content_array = [@content]
          render 'campaigns/wizard/create_content_on_campaign', :locals => {:single_content => @content_array }
        else
          redirect_to contents_path
        end
      end
  end

  def destroy
    @content.destroy
    redirect_to contents_path
  end

  def create_content_on_campaign
    @content = Content.new
  end

  private

  def get_content
    @content = @project.contents.find(params[:id])
  end

  def content_params
    params.require(:content).permit(:url, :multimedia, :duration).merge(:project_id => @project.id)
  end
end
