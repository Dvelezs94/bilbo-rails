class MonitorCampaignsWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, dead: false

  #This function has the option to check the impressions from all active campaigns (run periodically)
  #Or check if a campaign
  def perform(mode = "monitor impressions", campaign_id = nil)
    #Monitor all active campaigns (run every 4 hours)
    if mode == "monitor impressions"
      current_time = Time.now
      message = "Las siguientes campañas activas no están mostrándose en los bilbos indicados:\n"
      show_message = false
      Campaign.includes(:boards, :board_campaigns).active.where('state = true and starts_at < ? and ends_at > ?', current_time, current_time - 1.day).each do |campaign|
        not_running_boards = []
        campaign.board_campaigns.approved.each do |bc|
          add_board_to_list = false #Only used for campaigns per hour
          if bc.impressions_since_last_check > 0
            #Campaign is running fine, reset the counter and go to the next campaign
            bc.update_column(:impressions_since_last_check, 0)
            next
          end
          #The query from starts_at and ends_at doesn't consider Timezone changes, so we need to verify that the campaign
          #must be actually active, and if not, go to the next campaign, also, do not notify if less than 4 hours have passed since its start time
          next if campaign.time_to_start_in_board(bc.board) > -14400 or campaign.time_to_end_in_board(bc.board) + 86400 < 0

          if campaign.is_per_hour?
            #For campaigns per hour, check if the period since last check includes an interval of the campaign (totally or partially)
            time_in_board = Time.now.utc + bc.board.utc_offset.minutes
            previous_time_in_board = (time_in_board - 4.hours).strftime("%H:%M")
            time_in_board = time_in_board.strftime("%H:%M")
            campaign.impression_hours.each do |imp_hour|
              start_t = imp_hour.start.strftime("%H:%M")
              end_t = imp_hour.end.strftime("%H:%M")
              if time_intersection?(start_t, end_t, previous_time_in_board, time_in_board)
                add_board_to_list = true
                break
              end
            end
          end
          #Reaching this line means that the campaign is active in the board but there are no impressions, so we add it to the list
          not_running_boards.append(bc.board.slug) if !campaign.is_per_hour? or add_board_to_list
        end
        if not_running_boards.any?
          show_message = true
          ##Build the message for this campaign
          message += "#{campaign.name} (#{campaign.project.owner.email}):\n\t#{not_running_boards.join("\n\t")}\n"
        end
      end
      if Rails.env.production? && show_message
        #Notify in slack
        SlackNotifyWorker.perform_async(message)
      elsif show_message
        #Print in console
        puts message
      end

    #Check if campaign was approved on all of the selected boards (run once a day per campaign until its fully reviewed or finished)
    else
      return if campaign_id.nil?
      campaign = Campaign.find(campaign_id)
      campaign.update_column(:approval_monitoring, nil) #Remove this value so we know there isn't any worker monitoring this campaign at this moment
      return if campaign.ends_at < Time.now
      pending_boards = campaign.board_campaigns.where(status: "in_review").map{|bc| bc.board.slug}
      if pending_boards.any?
        if Rails.env.production?
          SlackNotifyWorker.perform_async("La campaña #{campaign.name} no ha sido aceptada o rechazada en los siguientes bilbos:\n\t#{pending_boards.join("\n\t")}")
        else
          puts "La campaña #{campaign.name} no ha sido aceptada o rechazada en los siguientes bilbos:\n\t#{pending_boards.join("\n\t")}"
        end
        worker_id = MonitorCampaignsWorker.perform_at(1.day.from_now, mode = "check approval", campaign_id = campaign.id) # if there is a pending board, set the worker to run again in one day
        campaign.update_column(:approval_monitoring, worker_id) #Let us know that another worker is monitoring this campaign now to avoid duplicated workers and messages on slack
      end
    end
  end

  def time_intersection?(start_1, end_1, start_2, end_2)
    #start_1 < end_2 && end_1 > start_2
    end_1 = (end_1.split(':')[0].to_i + 24).to_s + ':' +end_1.split(':')[1] if end_1 <= start_1
    end_2 = (end_2.split(':')[0].to_i + 24).to_s + ':' +end_2.split(':')[1] if end_2 <= start_2
    return start_1 < end_2 && end_1 > start_2
  end
end
