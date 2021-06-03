class ContentsController < ApplicationController
  access user: :all, provider: :all
  before_action :get_all_content, only: [:index]
  before_action :get_content, only: [:update, :destroy]

  def index
    @contents = @contents.page(params[:ad_upcoming_page]).per(10)
    respond_to do |format|
        format.js
        format.html
      end
  end

  def new_multimedia
    @content = Content.new
    if params[:content_modal].present?
      render  'new_multimedia'
    end
  end

  def new_url
    @content = Content.new
    if params[:content_modal].present?
      render  'new_url'
    end
  end

  def create_multimedia
    @content = @project.contents.create(multimedia: params[:multimedia])
    if !@content.save
        flash[:error] = "Error"
        redirect_to contents_path
    else
      respond_to do |format|
        @success_message = t("content.success")
        @content_array = [@content]
        @content_format = @content.get_format
        ref = Rails.application.routes.recognize_path(request.referrer)
        if ref[:controller] == "campaigns" && ref[:action] == "edit"
          format.js { render 'campaigns/wizard/create_content_on_campaign', :locals => {:single_content => @content_array, :message => @success_message, format: @content_format  }, :status => :created }
        else # else it was uploaded to content page
          format.js { render :template => "contents/create_multimedia.js.erb", :status => :created }
        end
      end
    end
  end

  def create_url
    @content = @project.contents.create(content_params)
    if !@content.save
        flash[:error] = "Error"
        redirect_to contents_path
    else
      @success_message = t("content.success")
      @content_array = [@content]
      if params[:content_modal].present? && params[:content_modal] == "false"
        render 'campaigns/wizard/create_content_on_campaign', :locals => {:single_content => @content_array, :message => @success_message  }
      elsif params[:content_modal].present? && params[:content_modal] == "true"
        render 'campaigns/wizard/create_content_on_campaign', :locals => {:single_content => @content_array, :message => @success_message }
      else # else it was uploaded to content page
        flash[:success] = @success_message
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

  def contents_modal_review
    if BoardsCampaigns.find(params[:id]).contents_board_campaign.present?
      if params[:images_only] == "true"
        @objects = []
        BoardsCampaigns.find(params[:id]).contents_board_campaign.each do |cbc|
          if cbc.content.is_image? || cbc.content.is_url?
            @objects.push(cbc.content)
          end
        end
      else
        @objects = []
        BoardsCampaigns.find(params[:id]).contents_board_campaign.map{|cbc| @objects.push(cbc.content)}
      end
      render  'contents_modal_review', :locals => {:obj => @objects}
    end
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

  def get_all_content
    @contents = @project.contents.order(created_at: :desc)
  end

  def content_params
    params.require(:content).permit(:url, :multimedia).merge(:project_id => @project.id)
  end
end
