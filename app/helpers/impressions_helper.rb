module ImpressionsHelper
    # helper to create impressions on a given date
    def create_custom_imp(imp_day, number_of_impressions, campaign_id, board_id, dry_run=true)
        # imp_day format should be "yyyy-mm-dd"
        # all impressions start at 11 AM just for sake of simplicity
        parsed_imp_day = imp_day.split("-")
        year = parsed_imp_day[0].to_i
        month = parsed_imp_day[1].to_i
        day = parsed_imp_day[2].to_i
    
        # initial parsed date
        parsed_date = Time.new(year, month, day, 11, 0, 0, "-05:00")
    
        for i in 0..(number_of_impressions - 1)
            # steps of each impression, by default bewteen 5 and 7 minutes
            steps = rand(300..450)
    
            parsed_date = parsed_date + steps
            if !dry_run
                Impression.create(
                    uuid: SecureRandom.hex(5), 
                    cycles: 1, 
                    api_token: Board.find(board_id).api_token, 
                    board_id: board_id, 
                    campaign_id: campaign_id,
                    duration: 10, 
                    created_at: parsed_date
                )
            else
                puts "DRY RUN - creating impression for day #{parsed_date}"
            end
        end
    end
end