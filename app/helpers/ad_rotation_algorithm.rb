module AdRotationAlgorithm
  extend ActiveSupport::Concern

  def test_ad_rotation(new_campaign, new_campaign_hours)
    err = []
    t_cycles = total_cycles(start_time, end_time)  #total of cycles of the bilbo

    if new_campaign.minutes.present? and self.duration != 10
      err << I18n.t("bilbos.ads_rotation_error.duration_is_not_ten", name: self.name)
      return err

    elsif new_campaign.minutes.present?
      displays, minutes = new_campaign.imp, new_campaign.minutes
      if minutes*6 < displays
        err << I18n.t("bilbos.ads_rotation_error.max_minutes_impressions", number: 6*minutes)
        return err
      end

    elsif new_campaign.clasification == "per_hour"
      new_campaign_hours.each do |cpn|
        if !valid_start(self, cpn)
          err << I18n.t("bilbos.ads_rotation_error.before_power_on", name: self.name)
          return err
        end
        reps = cpn.imp
        start_t = cpn.start
        end_t = cpn.end

        if !valid_end(self,cpn)
           err << I18n.t("bilbos.ads_rotation_error.after_power_off", name: self.name)
           return err
        end
        wm = working_minutes(start_t, end_t)
        if reps > (wm * 60/self.duration).to_i
          err << I18n.t("bilbos.ads_rotation_error.max_hour_impressions", number: (60*wm/self.duration).to_i)
          return err
        end
      end
      week = ImpressionHour.days.keys - ["everyday"]
      week.each do |week_day|
        items = new_campaign_hours.select{|c| c.day == "everyday" || c.day == week_day}
        if items.length > 1
          items.each_with_index do |item1,idx1|
            items.each_with_index do |item2,idx2|
              next if idx2 <= idx1
              start1, end1 = parse_hours(item1.start,item1.end)
              start2, end2 = parse_hours(item2.start,item2.end)
              if start1 < end2 and end1 > start2
                k1 = new_campaign_hours.index(item1)+1
                k2 = new_campaign_hours.index(item2)+1
                err << I18n.t("bilbos.ads_rotation_error.overlapping_schedules", n1: k1, n2: k2)
                return err
              end
            end
          end
        end
      end

    elsif new_campaign.provider_campaign && new_campaign.clasification == "budget" && new_campaign.budget.present?
       imp = (new_campaign.budget_per_bilbo/self.cycle_price).to_i
       if imp > t_cycles
         err << I18n.t("bilbos.ads_rotation_error.max_budget_impressions", name: self.name)
         return err
       end
    end
    return err
  end
 #################################################################################33
  def add_bilbo_campaigns
    output = JSON.parse(self.ads_rotation)

    cps  = self.campaigns.where(provider_campaign: false).select{ |c| c.should_run?(self.id) }.map{ |c| [ c.id, (c.budget_per_bilbo/self.cycle_price).to_i ] }.to_h # { john: 20, david: 26, will:  10} hese are the campaigns and the maximum times that can be displayed in the board
    cycles = []                            # array to store the name of the bilbo users the required times
    cps.each do |name, value|              # Fill the cycles array
       value.times do                      # with the names of the
           cycles << name                  # bilbo users
       end
    end

    free_idxs = free_indexes(output)
    cycles.shuffle!
    free_idxs.shuffle!

    cycles.each_with_index do |user, idx|
        x = free_idxs[idx]
        if x != nil
          output[x] = user
        else
          break
        end
    end
    return output

  end

  def build_ad_rotation(new_campaign = nil)

    err = []

    t_cycles = total_cycles(start_time, end_time)  #total of cycles of the bilbo
    output = []  #array to store the displays in the correct order

    t_cycles.times do   # Initialize the output
        output << '-'       # array with only bilbo
    end                     # ads

    r_cps_first = self.campaigns.where(provider_campaign: true, clasification: "budget").select{ |c| c.should_run?(self.id) }
    r_cps = r_cps_first.map{ |c| [ c.id, (c.budget_per_bilbo/self.cycle_price).to_i ] }.to_h#{p1: 60, p2: 50, p3:  67} #these are the required campaigns of the provider, same as cps
    r_cycles = []

    per_time_cps_first = self.campaigns.where(provider_campaign: true).where.not(minutes: nil,imp: nil).to_a.select{ |c| c.should_run?(self.id) }
    per_time_cps = per_time_cps_first.map{ |c| [ c.id,[c.imp, c.minutes] ]}.to_h  #Input hash for the x_campaings/y_minutes mode

    h_cps_first = []

    self.campaigns.where(provider_campaign: true, clasification: "per_hour").select{ |c| c.should_run?(self.id) }.each do |c|
      c.impression_hours.each do |cpn|
        if cpn.day == "everyday" || cpn.day == (Time.now.utc + self.utc_offset.minutes).strftime("%A").downcase
          h_cps_first.append(cpn)
        end
      end
    end

    #check if validation with new campaign (OPTIONAL!!)

    if new_campaign.present?
      if new_campaign.minutes.present?
        per_time_cps[new_campaign.id] = [new_campaign.imp, new_campaign.minutes]
      elsif new_campaign.impression_hours.present?
        new_campaign.impression_hours.each do |c|
          p (Time.now.utc - self.utc_offset.minutes).strftime("%A").downcase
          if c.day == "everyday" || c.day == (Time.now.utc + self.utc_offset.minutes).strftime("%A").downcase
            h_cps_first.append(c)
          end
        end
      elsif new_campaign.budget.present?
        r_cps[new_campaign.id] = (new_campaign.budget_per_bilbo/self.cycle_price).to_i
      end
    end
    #####################################
    h_cps_first.each do |c|
      if !hour_inside_board_time?(self,c)
        err << I18n.t("bilbos.ads_rotation_error.hour_campaign_time", name: self.name)
        return err
      end
    end

    h_cps = {}
    h_cps_first.each_with_index do |c,idx|
      p c
      p idx
      name = c.campaign_id.to_s << '/' << idx.to_s
      h_cps[name] = [c.imp,c.start,c.end]
    end
    h_cps = sort_by_min_time(h_cps)

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
       fi = (working_minutes(start_time,start_t,true)*60/self.duration).to_i
       la = (working_minutes(start_time,end_t,true)*60/self.duration).to_i

       value[1] = fi
       value[2] = la

       free = (fi...la).to_a

       free.shuffle!
       c = 0
       pos = 0
       while c < reps do

            if fi==la || free[pos].nil?
                err << I18n.t("bilbos.ads_rotation_error.hour_campaign_space", campaign_name: h_cps_first.find(id: name).name,bilbo_name: self.name)
                return err
                break
            end
            if output[free[pos]] == '-'
                c+=1
                output[free[pos]] = name
            else

                val = output[free[pos]]
                first = h_cps[val][1]
                last = h_cps[val][2]
                aux = output[first...last].index('-')
                if aux.nil?
                  err << I18n.t("bilbos.ads_rotation_error.hour_campaign_space", campaign_name: h_cps_first.find(id: name).name,bilbo_name: self.name)
                  return err
                  break
                else
                  output[aux+first] = val
                  c+=1
                  output[free[pos]] = name
                end
            end
            fi+=1
            pos+=1
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
        err << I18n.t("bilbos.ads_rotation_error.minute_campaign_space", campaign_name: per_time_cps_first.last.name, bilbo_name: self.name)
        return err
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
                        err << I18n.t("bilbos.ads_rotation_error.minute_campaign_space", campaign_name: per_time_cps_first.find(name).name, bilbo_name: self.name)
                        return err
                      end
                      output[h_cps[val][1]+idx] = val
                      output[inf+pos] = name
                      displays-=1
                    elsif arr.length<displays
                      err << I18n.t("bilbos.ads_rotation_error.minute_campaign_space", campaign_name: per_time_cps_first.find(name).name, bilbo_name: self.name)
                      return err
                    end
                end
                if arr.length == 0 and displays > 0
                    err << I18n.t("bilbos.ads_rotation_error.minute_campaign_space", campaign_name: per_time_cps_first.find(name).name, bilbo_name: self.name)
                    return err
                end
            end
            inf+=size
        end
    end

    free_spaces = output.count('-')
    if free_spaces < r_cycles.length
      err << I18n.t("bilbos.ads_rotation_error.budget_campaign_space", campaign_name: r_cps_first.last.name, bilbo_name: self.name)
      return err
    end

    free_idxs = free_indexes(output)
    free_idxs.shuffle!

    r_cycles.each_with_index do |user, idx|
        x = free_idxs[idx]
        if x != nil
          output[x] = user
        else
          break
        end
    end

    #PRINT THE RESULT ARRAY
    # output.each_slice(6).each_slice(5).each_with_index do |line, index|
    #     p [line, index+1]
    # end

    output.each_with_index do |item,idx|
      if item.is_a?(String) && item.index('/').present?
        item = item.split('/')[0].to_i
        output[idx]=item
      end
    end

    self.new_ads_rotation = output
    return err

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
def hour_inside_board_time?(brd, c)
  return (valid_start(brd,c) && valid_end(brd,c))
end
def valid_start(brd,c)
  st = get_time(brd.start_time)
  et = get_time(brd.end_time)
  return true if et == st
  et+=1.day if et<st
  cst = get_time(c.start)
  return cst.between?(st,et)
end
def valid_end(brd,c)
  st = get_time(brd.start_time)
  et = get_time(brd.end_time)
  return true if et == st
  et+=1.day if et<st
  cst = get_time(c.start)
  cet = get_time(c.end)
  cet+=1.day if cet<cst
  return cet.between?(st,et)
end
def get_time(the_time)
  t = the_time.strftime("%H:%M")
  t = Time.parse(t)
end
def parse_hours(start_t,end_t)
  start_t = get_time(start_t)
  board_start = get_time(start_time)
  end_t = get_time(end_t)
  start_t += 1.day if start_t < board_start
  end_t += 1.day if start_t >= end_t
  return start_t,end_t
end
end
