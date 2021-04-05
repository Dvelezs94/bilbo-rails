class ContentsBoardCampaignController < ApplicationController
  def multimedia
    #Return the content for modal step 2 for show bilbos
    if Board.find_by_slug(params[:board_slug]).images_only
      @content = []
      Campaign.find(params[:campaign]).project.contents.each do |content|
        if !content.is_video?
          @content.push(content)
        end
      end
    else
      @content = Campaign.find(params[:campaign]).project.contents.map{|content| content}
    end
    @board_name = params[:board_name]
    @slug = params[:board_slug]
    render  'campaigns/wizard/multimedia', :locals => {:content => @content, :board_name => @board_name, :slug => @slug}
  end

  def get_content
    #Return the selected contents to bilbos on step 2
    @selected_contents = Content.where(id: params[:selected_contents].split(" "))
    @board_slug = params[:board_slug]
    render  'campaigns/wizard/get_content', :locals => {:selected_content => @selected_contents, :board_slug => @board_slug}
  end
end
