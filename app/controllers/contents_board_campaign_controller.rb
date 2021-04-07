class ContentsBoardCampaignController < ApplicationController
  def multimedia
    #Return the content for modal step 2 for show bilbos
    board = Board.friendly.find(params[:board_slug])
    @accept_only_images = board.images_only
    @campaign = Campaign.find(params[:campaign])
    if @accept_only_images
      @content = []
      @campaign.project.contents.each do |content|
        if !content.is_video?
          @content.push(content)
        end
      end
    else
      @content = Campaign.find(params[:campaign]).project.contents.map{|content|content}
    end
    @board_name = params[:board_name]
    @slug = params[:board_slug]
    render  'campaigns/wizard/multimedia', :locals => {:content => @content, :board_name => @board_name, :slug => @slug, :accept_only_images => @accept_only_images, :campaign => @campaign}
  end

  def get_content
    #Return the selected contents to bilbos on step 2
    @selected_contents = Content.where(id: params[:selected_contents].split(" "))
    @board_slug = params[:board_slug]
    @board = Board.friendly.find(params[:board_slug])
    @campaign = params[:campaign]
    render  'campaigns/wizard/get_content', :locals => {:selected_content => @selected_contents, :board => @board, :campaign => @campaign}
  end
end
