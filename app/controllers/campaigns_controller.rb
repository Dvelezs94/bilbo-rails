class CampaignsController < ApplicationController
  include UserActivityHelper
  access [:user, :provider] => :all, all: [:analytics, :shortened_analytics, :redirect_to_external_link, :get_boards_content_info]
  before_action :get_campaigns, only: [:index]
  before_action :get_campaign, only: [:edit, :destroy, :update, :toggle_state, :get_used_boards, :download_qr_instructions, :copy_campaign, :create_copy, :get_used_contents, :get_boards_content_info]
  before_action :verify_identity, only: [:edit, :destroy, :update, :toggle_state, :get_used_boards, :get_used_contents, :get_boards_content_info]
  before_action :campaign_not_active, only: [:edit]

  def index
    @created_ads = @project.contents.present?
    @created_campaigns = @project.campaigns.present?
    @purchased_credits = current_user.payments.present?
    @verified_profile = current_user.verified
    @show_hint = !(@created_ads && @created_campaigns && @purchased_credits && @verified_profile)
    if params[:witness].present?
      @witness = Witness.find(params[:witness])
    end
  end

  def provider_index
    if params[:q] == "review"
      Campaign.active.joins(:boards).merge(@project.boards).uniq.pluck(:id).each do |c|
        @campaign_loop = Campaign.find(c)
        # to be optimized
        if @campaign_loop.owner.has_had_credits? || @campaign_loop.provider_campaign?
          @camp = Array(@camp).push(c)
        end
      end
      @board_campaigns = BoardsCampaigns.where(board_id: @project.boards.enabled.pluck(:id), campaign_id: @camp).in_review
    elsif params[:bilbo].present?
      @board_campaigns = BoardsCampaigns.where(board_id: @project.boards.enabled.friendly.find(params[:bilbo]), campaign_id: Campaign.active.joins(:boards).merge(@project.boards).uniq.pluck(:id)).approved rescue nil
    else
      @board_campaigns = BoardsCampaigns.where(board_id: @project.boards.enabled.pluck(:id), campaign_id: Campaign.active.joins(:boards).merge(@project.boards).uniq.pluck(:id)).approved
    end
  end

  def get_content
    campaign = Campaign.find(params[:id])
    if campaign.should_run?(params[:board_id].to_i)
      content = Board.find(params[:board_id]).get_content(campaign)
      @append_msg = ApplicationController.renderer.render(partial: "campaigns/board_campaign", collection: content, as: :media, locals: {campaign: campaign})
    else
      @append_msg = ""
    end
  end

  def get_used_boards
    @board_campaigns = @campaign.board_campaigns.includes(:board, :contents_board_campaign)
  end

  def get_used_contents
   @board_campaigns = BoardsCampaigns.find(params[:board_campaign])
   @contents = @board_campaigns.contents_board_campaign
  end

  def analytics
    @date_start = Date.parse(params[:date_start]) rescue 30.days.ago
    @date_end = DateTime.parse(params[:date_end]) rescue Time.zone.now
    @campaign = Campaign.includes(:boards, :impressions).friendly.find(params[:id])
    @history_campaign = UserActivity.where( activeness: @campaign).order(created_at: :desc)
    @witnesses = @campaign.witnesses.order(created_at: :desc)
    @witness = Witness.new
    @campaign_impressions = time_range_init(@date_start, @date_end)
    @impressions = Impression.where(campaign: @campaign, created_at: @date_start..@date_end)
    @total_invested = @campaign.total_invested
    @total_impressions = @impressions.count
    @impressions.group_by_day(:created_at).count.each do |key, value|
      @campaign_impressions[key] = {impressions_count: value, total_invested: @impressions.group_by_day(:created_at).sum(:total_price)[key].round(3)}
    end
    return @campaign_impressions
  end

  def edit
    if @campaign.ad.present?
      @ads = @project.ads.active.where.not(id: @campaign.ad).order(updated_at: :desc).with_attached_multimedia.select{ |ad| ad.multimedia.any? }
      @ads.prepend(@campaign.ad)
    else
      @ads = @project.ads.active.order(updated_at: :desc).with_attached_multimedia.select{ |ad| ad.multimedia.any? }
    end
    @ad_upcoming = Kaminari.paginate_array(@ads).page(params[:ad_upcoming_page]).per(11)
    factor = (@campaign.classification == "per_hour" && !@campaign.provider_campaign?)? 1.2 : 1
    @campaign_boards =  @campaign.boards.enabled.collect { |board| ["#{board.address} - #{board.face}", board.id, { 'data-max-impressions': JSON.parse(board.ads_rotation).size, 'data-price': factor*board.sale_cycle_price/board.duration, 'new-height': board.size_change[0].round(0), 'new-width': board.size_change[1].round(0), 'data-cycle-duration': board.duration, 'data-factor': factor, 'data-slug': board.slug } ] }
    @campaign.starts_at = @campaign.starts_at.to_date rescue ""
    @campaign.ends_at = @campaign.ends_at.to_date rescue ""
    if current_user.is_provider?
      @boards = @project.boards
    else
      @boards = Board.enabled
    end
    respond_to do |format|
        format.js
        format.html
      end
  end

  def toggle_state
    current_user.with_lock do
      @campaign.with_lock do
        @success = @campaign.update(state: !@campaign.state)
      end
      if @success
        if @campaign.state
          track_activity( action: "campaign.campaign_actived", activeness: @campaign)
        else
          track_activity( action: "campaign.campaign_deactivated", activeness: @campaign)
        end
      end
    end
  end


  def update
    begin
      current_user.with_lock do
        respond_to do |format|
          @campaign.board_campaigns.where.not(board_id: campaign_params[:boards]).map{ |bc| bc.destroy}
          if @campaign.update(campaign_params.merge(state: is_state, owner_updated_campaign: true))
            track_activity( action: "campaign.campaign_updated", activeness: @campaign)
            # Create a notification per project
            @campaign.boards.includes(:project).map(&:project).uniq.each do |provider|
            # send notification only if the owner of the project has credits
            if @campaign.owner.has_had_credits?
              create_notification(recipient_id: provider.id, actor_id: @campaign.project.id,
                                  action: "created", notifiable: @campaign,
                                  sms: !current_user.is_provider?)
            end
            if @campaign.starts_at.present? && @campaign.ends_at.present?
              @campaign.boards.each do |b|
                #difference_in_seconds = (@campaign.to_utc(@campaign.starts_at, b.utc_offset) - Time.now.utc).to_i
                #difference_in_seconds_end = (@campaign.to_utc(@campaign.ends_at, b.utc_offset) - Time.now.utc).to_i
                difference_in_seconds = (@campaign.starts_at - Time.now).to_i
                difference_in_seconds_end = (@campaign.ends_at - Time.now).to_i
                ScheduleCampaignWorker.perform_at(difference_in_seconds.seconds.from_now, @campaign.id, b.id) if difference_in_seconds > 0
                RemoveScheduleCampaignWorker.perform_at((difference_in_seconds_end.seconds+86401.seconds).from_now, @campaign.id, b.id) if difference_in_seconds_end > 0
              end
            end
          end
            format.js {
              flash[:success] = I18n.t('campaign.action.updated')
              if request.referer.include?("gtm_campaign_create")
                redirect_to campaigns_path(gtm_creation: "complete")
              elsif request.referer.include?("gtm_campaign_edit")
                redirect_to campaigns_path(gtm_edit: "complete")
              else
                redirect_to campaigns_path
              end
             }
            format.json { head :no_content }
          else
            format.js {
              #nothing, just view
               }
            format.json { render json: @campaign.errors, status: :unprocessable_entity }
            raise ActiveRecord::Rollback
          end
        end
      end
    rescue => e
      format.json { render json: @campaign.errors, status: :unprocessable_entity }
      raise e
    end
  end

  def create
    @campaign = Campaign.new(create_params)
      if @campaign.save
        track_activity(action: 'campaign.campaign_created', activeness: @campaign)
      else
        flash[:error] = I18n.t('campaign.errors.no_save')
      end
      if @campaign.interaction?
        render "create_interaction"
      else
        redirect_to edit_campaign_path(@campaign, gtm_campaign_create: true)
      end
  end

  def destroy
    if !@campaign.state?
      # Skip validations because the campaign is already disabled
      @campaign.update_attribute(:status, "inactive")
      respond_to do |format|
        format.html {
          flash[:success] = I18n.t('campaign.action.deleted')
           redirect_to campaigns_path
         }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html {
          flash[:error] = I18n.t('campaign.errors.cant_update_when_active')
          redirect_to campaigns_path
         }
        format.json { head :no_content }
      end
    end
  end

  def shortened_analytics
    if params[:id].present?
      @campaign = Campaign.find_by_analytics_token(params[:id])
      redirect_to analytics_campaign_path(@campaign.slug)
    end
  end

  # method to redirect the user to the campaign external link
  def redirect_to_external_link
    @campaign = Campaign.friendly.find(params[:id])
    if !@campaign.link.to_s.empty?
      redirect_to @campaign.link
    else
      render "external_link_empty"
    end
  end

  def download_qr_instructions
    qr_files_location = build_qr_instruction_files(@campaign)
    require 'zip'
    #Attachment name
    filename = "QR - #{@campaign.name}.zip"
    temp_file = Tempfile.new(filename)

    begin
      #This is the tricky part
      #Initialize the temp file as a zip file
      Zip::OutputStream.open(temp_file) { |zos| }

      #Add files to the zip file as usual
      Zip::File.open(temp_file.path, Zip::File::CREATE) do |zip|
        for dir_file in Dir["#{qr_files_location}/*"]
          zip.add(dir_file.split("/").last, dir_file)
        end
      end

      #Read the binary data from the file
      zip_data = File.read(temp_file.path)

      #Send the data to the browser as an attachment
      #We do not send the file directly because it will
      #get deleted before rails actually starts sending it
      send_data(zip_data, :type => 'application/zip', :filename => filename)
    ensure
      #Close and delete the temp file
      temp_file.close
      temp_file.unlink
    end
  end

  def create_copy
    camp = @campaign.amoeba_dup
    camp.assign_attributes(copy_params)
    camp.board_campaigns.each { |boardcampaign| boardcampaign.assign_attributes(status: "in_review") } if camp.board_campaigns.present?
    if camp.save
      track_activity( action: 'campaign.campaign_created', activeness: camp)
      flash[:success] = I18n.t('campaign.action.saved')
    else
      flash[:error] = I18n.t('campaign.errors.no_save')
    end
    redirect_to edit_campaign_path(camp, gtm_campaign_create: true)
  end

  def copy_campaign
    render 'copy_campaign', :locals => {:obj => @campaign}
  end

  # this gets called in the second step of wizard for call the boards
  def get_boards_content_info
    @campaign
    @selected_boards = Board.where(id: params[:selected_boards].split(","), status: "enabled")
  end

  private

  def campaign_params
    @campaign_params = params.require(:campaign).permit(:name, :description, :boards, :starts_at, :ends_at, :budget, :link, :imp, :minutes, :duration, :content_ids, impression_hours_attributes: [:id, :day, :imp, :start, :end, :_destroy] ).merge(:project_id => @project.id)
    if @campaign_params[:boards].present?
      @campaign_params[:boards] = Board.where(id: @campaign_params[:boards].split(",").reject(&:empty?))
    end

    @campaign_params[:starts_at] = nil if @campaign_params[:starts_at].nil?
    @campaign_params[:ends_at] = nil if @campaign_params[:ends_at].nil?

    if @campaign_params[:budget].present?
      @campaign_params[:budget] = @campaign_params[:budget].tr(",","").to_f

    #else
     # @campaign_params[:budget] = nil
    end
    @campaign_params
  end

  def create_params
    @campaign_params = params.require(:campaign).permit(:name, :description, :provider_campaign, :classification, :link, :objective).merge(:project_id => @project.id)
    @campaign_params[:provider_campaign] = @project.classification == 'provider'
    @campaign_params
  end

  def copy_params
    @campaign_params = params.require(:campaign).permit(:name, :description)
    @campaign_params[:state] = false
    @campaign_params[:impression_count] = 0
    @campaign_params[:total_invested] = 0
    @campaign_params
  end

  def get_campaigns
    @campaigns = @project.campaigns.includes(:boards).active
  end

  def get_campaign
    @campaign = Campaign.includes(:boards, :impressions).where(project: @project).friendly.find(params[:id])
  end

  def verify_identity
    redirect_to campaigns_path if not @campaign.project.users.pluck(:id).include? current_user.id
  end

  def campaign_not_active
    if @campaign.state
      flash[:error] = I18n.t('campaign.errors.cant_update_when_active')
      redirect_back fallback_location: root_path
    end
  end

  # sets the campaign state automatically
  def is_state
    if current_user.is_user?
      # if owner is verified, then enable campaign automatically
      if @campaign.owner.verified
        true
      else
        false
      end
    # always enable campaigns automatically by providers
    elsif current_user.is_provider?
      return true
    else
      return false
    end
  end

  # build the files for the QR
  def build_qr_instruction_files(campaign)
    hex = SecureRandom.hex(4)
    tmp_dir = "/tmp/#{hex}"
    # create directory
    Dir.mkdir(tmp_dir) unless File.exists?(tmp_dir)
    # create files
    File.open("#{tmp_dir}/qr-#{campaign.name}.png", "wb") { |f| f.write campaign.qr_shortener.png_to_text }
    File.open("#{tmp_dir}/#{I18n.t('campaign.qr.file_name')}.txt", "wb") { |f|
      f.write I18n.t('campaign.qr.file_content', name: current_user.name, campaign_edit_link: edit_campaign_url(campaign))
    }
    return tmp_dir
  end

  def time_range_init(date_start, date_end)
    date_end = date_end.to_date
    date_start = date_start.to_date
    time_range = {}
    while date_start <= date_end do
      time_range[date_start] = {impressions_count: 0, total_invested: 0}
      date_start += 1.day
    end
    return time_range
  end
end
