class ContentsBoardCampaignController < ApplicationController
  def get_contents_wizard_modal
    #Return the content for modal step 2
    @board = Board.friendly.find(params[:board_slug])
    @campaign = Campaign.friendly.find(params[:campaign])
    if @board.images_only
      @content = []
      @campaign.project.contents.each do |content|
        if !content.is_video?
          @content.push(content)
        end
      end
    else
      @content = Campaign.friendly.find(params[:campaign]).project.contents.map{|content|content}
    end
    render  'campaigns/wizard/get_contents_wizard_modal', :locals => {:content => @content, :board => @board, :campaign => @campaign}
  end

  def get_selected_content
    #Return the selected contents for show bilbos
    @selected_contents = Content.where(id: params[:selected_contents].split(" "))
    @board = Board.friendly.find(params[:board_slug])
    @campaign = params[:campaign]
    render  'campaigns/wizard/get_selected_content', :locals => {:selected_content => @selected_contents, :board => @board, :campaign => @campaign}
  end
end
