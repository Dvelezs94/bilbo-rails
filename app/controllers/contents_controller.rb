class ContentsController < ApplicationController
  access user: :all, provider: :all, admin: :all
  before_action :get_all_content, only: [:index]
  before_action :get_content, only: [:update, :destroy]

  def index
    @contents = @contents.page(params[:upcoming_page]).per(15)
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
    @content = current_project.contents.create(multimedia: params[:multimedia])
    respond_to do |format|
      if !@content.save
          format.js { render js: @content.errors.full_messages.first, status: 500 }
      else
          @success_message = t("content.success")
          @content_array = [@content]
          @content_format = @content.get_format
          ref = Rails.application.routes.recognize_path(request.referrer)
          if (ref[:controller] == "campaigns" && ref[:action] == "edit") || (ref[:controller] == "boards" && ref[:action] == "owned")
            format.js { render 'campaigns/wizard/create_content_on_campaign', :locals => {:single_content => @content_array, :message => @success_message, format: @content_format  }, :status => :created }
          else # else it was uploaded to content page
            format.js { render :template => "contents/create_multimedia.js.erb", :status => :created }
          end
        end
      end
  end

  def create_url
    @content = current_project.contents.create(content_params)
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
      if !@content.destroy
        flash[:error] = @content.errors.full_messages.first
      else
        flash[:success] = I18n.t('ads.action.content_deleted')
      end
    end
    redirect_to contents_path
  end

  def create_content_on_campaign
    @content = Content.new
  end

  def contents_modal_review
    board_campaign = BoardsCampaigns.find(params[:id])
    @board = board_campaign.board
    if board_campaign.contents_board_campaign.present?
      if params[:images_only] == "true"
        @objects = []
        board_campaign.contents_board_campaign.each do |cbc|
          if cbc.content.is_image? || cbc.content.is_url?
            @objects.push(cbc.content)
          end
        end
      else
        @objects = []
        board_campaign.contents_board_campaign.map{|cbc| @objects.push(cbc.content)}
      end
      render  'contents_modal_review', :locals => {:obj => @objects, :board => @board}
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
    @content = current_project.contents.find(params[:id])
  end

  def get_all_content
    @contents = current_project.contents.order(created_at: :desc)
  end

  def content_params
    params.require(:content).permit(:url, :multimedia).merge(:project_id => current_project.id)
  end
end
