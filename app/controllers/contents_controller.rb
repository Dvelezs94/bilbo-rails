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
    @content = Content.new
    @content_modal = params[:content_modal]
    if params[:content_modal].present?
      render  'new_multimedia', :locals => {:content_modal => @content_modal}
    end
  end

  def update
    if @content.update(content_params)
      flash[:success] = "Success"
    end
  end

  def create
    @content = @project.contents.create(content_params)
    if  @content.multimedia.present?
      @content.multimedia_derivatives!
    end
    if !@content.save
        flash[:error] = "Error"
        redirect_to contents_path
      else
        flash[:success] = "Success"
        @content_array = [@content]
        if params[:content_modal].present? && params[:content_modal] == "false"
          @success_message = "Se subio con exito el contenido"
          render 'campaigns/wizard/create_content_on_campaign', :locals => {:single_content => @content_array, :message => @success_message  }
        elsif params[:content_modal].present? && @content.is_image? && params[:content_modal] == "true"
          @success_message = "Se subio con exito el contenido"
          render 'campaigns/wizard/create_content_on_campaign', :locals => {:single_content => @content_array, :message => @success_message }
        elsif params[:content_modal].present? && @content.is_video? && params[:content_modal] == "true"
          @success_message = "Se subio con exito el contenido, solo que este bilbo no acepta videos"
          render 'campaigns/wizard/message_upload', :locals => { :message => @success_message }
        else
          redirect_to contents_path
        end
      end
  end

  def destroy
    if content_in_use
      flash[:error] = I18n.t('ads.errors.cant_delete_content')
    else
      @content.destroy
      flash[:success] = I18n.t('ads.action.content_deleted')
    end
    redirect_to contents_path
  end

  def create_content_on_campaign
    @content = Content.new
  end

  private

  def content_in_use
    #Check if there is any active campaign with that content
    bc = ContentsBoardCampaign.where(content: @content).pluck(:boards_campaigns_id).uniq
    if Campaign.where(id: BoardsCampaigns.where(id: bc).select(:campaign_id)).select_active.any?
      return true
    end
    return false
  end

  def get_content
    @content = @project.contents.find(params[:id])
  end

  def content_params
    params.require(:content).permit(:url, :multimedia).merge(:project_id => @project.id)
  end
end
