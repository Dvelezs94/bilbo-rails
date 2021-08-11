class ContentsBoardCampaignController < ApplicationController
  access [:user, :provider] => :all
  before_action :verify_identity

  def get_contents_wizard_modal
    #Return the content for modal step 2
    @slug = params[:board_slug]
    @slug.slice! "slug-"
    @board = Board.friendly.find(@slug)
    @campaign = Campaign.friendly.find(params[:campaign])
    contents = []
    #Returns the selected contents to the beginning of the modal if they exist
    if BoardsCampaigns.find_by(campaign_id: @campaign.id, board_id: @board.id).present?
      BoardsCampaigns.find_by(campaign_id: @campaign.id, board_id: @board.id).contents_board_campaign.each do |content|
        contents.push(Content.find(content.content_id))
      end
    end
    if @board.images_only
      @campaign.project.contents.order(id: :desc).each do |content|
        if !content.is_video?
          contents.push(content)
        end
      end
    else
      @campaign.project.contents.order(id: :desc).map{|content|contents.push(content)}
    end
    @content = Kaminari.paginate_array(contents.uniq).page(params[:upcoming_page]).per(15)
    render  'campaigns/wizard/get_contents_wizard_modal', :locals => {:content => @content, :board => @board, :campaign => @campaign}
  end

  def get_selected_content
    @slug = params[:board_slug]
    @slug.slice! "slug-"
    #Return the selected contents for show bilbos
    @selected_contents = Content.where(id: params[:selected_contents].split(" "))
    @board = Board.friendly.find(@slug)
    @campaign = params[:campaign]
    render  'campaigns/wizard/get_selected_content', :locals => {:selected_content => @selected_contents, :board => @board, :campaign => @campaign}
  end

  def get_all_selected_contents
    @selected_contents = {}
    default_rows_per_day = {"monday" => 0, "tuesday" => 0, "wednesday" => 0, "thursday" => 0, "friday" => 0, "saturday" => 0, "sunday" => 0}
    @rows_per_day = default_rows_per_day.merge(JSON.parse(params[:table_rows]))
    p @rows_per_day
    JSON.parse(params[:selected_contents]).each do |slug, content_ids|
      @selected_contents[slug.to_sym] = Content.where(id: content_ids.split(' '))
    end
    render  'campaigns/wizard/get_all_selected_contents', :locals => {:selected_content => @selected_contents, :board => @board, :campaign => @campaign}
  end

  def fetch_single_wizard_content
    @content = Content.find(params[:id])
  end

  private
  def verify_identity
    raise_not_found if not @project.users.pluck(:id).include? current_user.id
  end
end
