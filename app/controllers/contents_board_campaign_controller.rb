class ContentsBoardCampaignController < ApplicationController
  access [:user, :provider] => :all
  before_action :verify_identity

  def get_contents_wizard_modal
    #Return the content for modal step 2
    @slug = params[:board_slug]
    @slug.slice! "slug-"
    @board = Board.friendly.find(@slug)
    @campaign = Campaign.friendly.find(params[:campaign])
    if @board.images_only
      contents = []
      @campaign.project.contents.order(id: :asc).each do |content|
        if !content.is_video?
          contents.push(content)
        end
      end
    else
      contents = Campaign.friendly.find(params[:campaign]).project.contents.order(id: :desc).map{|content|content}
    end
    @content = Kaminari.paginate_array(contents).page(params[:upcoming_page]).per(15)
    p @content
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

  def fetch_single_wizard_content
    @content = Content.find(params[:id])
  end

  private
  def verify_identity
    raise_not_found if not @project.users.pluck(:id).include? current_user.id
  end
end
