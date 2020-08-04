module AdRotationAlgorithm
  extend ActiveSupport::Concern

  def test_ad_rotation(new_campaign)
    valid = false
    err = []

    t_cycles = total_cycles(start_time, end_time)  #total of cycles of the bilbo

    if new_campaign.minutes.present?
      displays, minutes = new_campaign.imp, new_campaign.minutes
      if minutes*6 < displays
        err << I18n.t("bilbos.ads_rotation_error.max_minutes_impressions", number: 6*minutes)
        return valid, err
      end

    elsif new_campaign.hour_start.present?
      if (self.start_time < self.end_time && !new_campaign.hour_start.between?(self.start_time, self.end_time)) || ( self.start_time > self.end_time ) && new_campaign.hour_start.between?(self.end_time, self.start_time)
        err << I18n.t("bilbos.ads_rotation_error.before_power_on", name: self.name)
        return valid, err
      end
      reps = new_campaign.imp
      start_t = new_campaign.hour_start
      end_t = new_campaign.hour_finish
      fi = working_minutes(start_time,start_t,true)*6
      la = working_minutes(start_time,end_t,true)*6

      if la > t_cycles
         err << I18n.t("bilbos.ads_rotation_error.after_power_off", name: self.name)
         return valid, err
      end
      wm = working_minutes(start_t, end_t)
      if reps > wm * 6
        err << I18n.t("bilbos.ads_rotation_error.max_hour_impressions", number: 6*wm)
        return valid, err
      end

    elsif new_campaign.provider_campaign && new_campaign.clasification == "budget"
       imp = (new_campaign.budget_per_bilbo/self.cycle_price).to_i
       if imp > t_cycles
         err << I18n.t("bilbos.ads_rotation_error.max_budget_impressions", name: self.name)
         return valid, err
       end
    end
    valid = true
    return valid, err
  end
 #################################################################################33
  def build_ad_rotation(new_campaign = nil)

    err = []

    t_cycles = total_cycles(start_time, end_time)  #total of cycles of the bilbo
    output = []  #array to store the displays in the correct order

    t_cycles.times do   # Initialize the output
        output << '-'       # array with only bilbo
    end                     # ads
    cps  = self.campaigns.where(provider_campaign: false).to_a.select{ |c| c.should_run?(self.id) }.map{ |c| [ c.id, (c.budget_per_bilbo/self.cycle_price).to_i ] }.to_h # { john: 20, david: 26, will:  10} hese are the campaigns and the maximum times that can be displayed in the board
    cycles = []                            # array to store the name of the bilbo users the required times

    r_cps = self.campaigns.where(provider_campaign: true, clasification: "budget").to_a.select{ |c| c.should_run?(self.id) }.map{ |c| [ c.id, (c.budget_per_bilbo/self.cycle_price).to_i ] }.to_h#{p1: 60, p2: 50, p3:  67} #these are the required campaigns of the provider, same as cps
    r_cycles = []

    per_time_cps = self.campaigns.where(provider_campaign: true).where.not( minutes: nil).where.not(imp: nil).to_a.select{ |c| c.should_run?(self.id) }.map{ |c| [ c.id,[c.imp, c.minutes] ]}.to_h  #Input hash for the x_campaings/y_minutes mode

    h_cps = self.campaigns.where(provider_campaign: true).where.not(hour_start: nil).where.not(hour_finish: nil).where.not(imp: nil).to_a.select{ |c| c.should_run?(self.id) }.map{ |c| [ c.id,[c.imp, c.hour_start, c.hour_finish] ]}.to_h
    h_cps = sort_by_min_time(h_cps)

    #check if validation with new campaign (OPTIONAL!!)

    if new_campaign.present?
      if new_campaign.minutes.present?
        per_time_cps[new_campaign.id] = [new_campaign.imp, new_campaign.minutes]
      elsif new_campaign.hour_start.present?
        h_cps[new_campaign.id] = [new_campaign.imp, new_campaign.hour_start, new_campaign.hour_finish]
      elsif new_campaign.provider_campaign
        r_cps[new_campaign.id] = (new_campaign.budget_per_bilbo/self.cycle_price).to_i
      end
    end
    #####################################

    cps.each do |name, value|              # Fill the cycles array
       value.times do                      # with the names of the
           cycles << name                  # bilbo users
       end
    end
    r_cps.each do |name, displays|
        displays.times do
            r_cycles << name
        end
    end
    per_time_cps.each do |name, value|
        r = Rational(value[0],value[1])
        value[0] = r.numerator
        value[1] = r.denominator
    end

    ########## PLACE THE H_CPS AT THE START OF THEIR RESPECTIVE HOURS ##############
    h_cps.each do |name, value|
       reps = value[0]
       start_t = value[1]
       end_t = value[2]
       fi = working_minutes(start_time,start_t,true)*6
       la = working_minutes(start_time,end_t,true)*6

       h_cps[name][1] = fi
       h_cps[name][2] = la
       c = 0
       while c < reps do

            if fi==la
                err << I18n.t("bilbos.ads_rotation_error.hour_campaign_space", name: self.name)
                return output, err
                break
            end
            if output[fi] == '-'
                c+=1

                output[fi] = name
            end
            fi+=1
       end
    end
    ################################################################################

    total_h = 0                                 # compute the number of spaces used
    h_cps.each {|name, val| total_h+=val[0]}    # to know the free spaces left

    per_time_cps_cp = Marshal.load(Marshal.dump(per_time_cps))
    per_time_cps_cp = translate_hash(per_time_cps_cp,t_cycles)

    sum = 0
    per_time_cps_cp.each {|key,value| sum+=value}

    if sum + total_h> t_cycles
        err << I18n.t("bilbos.ads_rotation_error.minute_campaign_space", name: self.name)
        return output, err
        #abort
    end

    per_time_cps = sort_by_max_repetitions(per_time_cps)

    per_time_cps.each do |name, displays_minutes|
        minutes = displays_minutes[1]
        size = minutes*6
        inf = 0

        while inf < t_cycles do
            arr = (0...size).to_a
            displays = displays_minutes[0]
            if inf+size <= t_cycles
                x = output[inf...inf+size]
                while displays>0
                    arr.shuffle!
                    pos = arr[0]
                    arr.delete_at(0)
                    if output[inf+pos] == '-'
                      output[inf+pos] = name
                      displays-=1
                    elsif h_cps.keys.include? output[inf+pos]
                      val = output[inf+pos]
                      idx = output[h_cps[val][1]...h_cps[val][2]].index('-')
                      if idx.nil?
                        err << I18n.t("bilbos.ads_rotation_error.minute_campaign_space", name: self.name)
                        return output, err
                      end
                      output[idx] = val
                      output[inf+pos] = name
                      displays-=1
                    elsif arr.length<displays
                      err << I18n.t("bilbos.ads_rotation_error.minute_campaign_space", name: self.name)
                      return output, err
                    end
                end
                if arr.length == 0 and displays > 0
                    err << I18n.t("bilbos.ads_rotation_error.minute_campaign_space", name: self.name)
                    return output, err
                end
            end
            inf+=size
        end
    end

    free_spaces = output.count('-')
    if free_spaces < r_cycles.length
      err << I18n.t("bilbos.ads_rotation_error.budget_campaign_space", name: self.name)
      return output, err
    else
        n = [cycles.length, free_spaces - r_cycles.length].min
        cycles.shuffle!
        for i in 0...n
            r_cycles << cycles[i]
        end
    end

    free_idxs = free_indexes(output)
    free_idxs.shuffle!

    r_cycles.each_with_index do |user, idx|
        x = free_idxs[idx]
        if x != nil
            output[x] = user
        end
    end

    #PRINT THE RESULT ARRAY
    output.each_slice(6).each_slice(5).each_with_index do |line, index|
        p [line, index+1]
    end

    ###### AUTOMATICALLY CHECK IF THE PROGRAM RAN CORRECTLY ##########
    # Check scheduled cps
    p "FINAL DE EJECUCION"
    p "LA EJECUCION FUE EXITOSA" if err.empty?
    return output, err

  end


  private
  ############# HELP FUNCTIONS #########################
def sort_by_max_repetitions(hash)
    hash.sort_by {|key, value| -value[0]/value[1]}
    return hash
end
def sort_by_min_time(hash)
    hash.sort_by {|key, value| working_minutes(value[1],value[2])}
    return hash
end

def translate_hash(per_time_cps,t_cycles)

    per_time_cps.each do |name, displays_minutes|      #Translate the per_time_cps format
        displays = displays_minutes[0]                  #to make it similar to the cps and r_cps
        minutes = displays_minutes[1]
        reps = t_cycles*displays/(minutes*6)
        per_time_cps[name] = reps
    end
    per_time_cps_aux = per_time_cps.sort_by{|key, value| -value}
    per_time_cps = []
    per_time_cps_aux.each do |key, value|
        per_time_cps << key
        per_time_cps << value
    end
    per_time_cps = Hash[*per_time_cps]
    return per_time_cps
end
def free_indexes(array)
    result = []
    array.each_with_index do |item, index|
        if item == "-"
            result << index
        end
    end
    return result #gets the indexes of the empty cells of the array
end
end
