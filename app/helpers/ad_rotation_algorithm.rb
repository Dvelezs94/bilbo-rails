module AdRotationAlgorithm
  extend ActiveSupport::Concern

  def test_ad_rotation(new_campaign, new_campaign_hours)
    err = []
    t_cycles = total_cycles(start_time, end_time)  #total of cycles of the bilbo

    if new_campaign.ad.duration < self.duration
      err << I18n.t("bilbos.ads_rotation_error.ad_duration_less_than_required", name: self.name)
      return err

    elsif new_campaign.minutes.present? and new_campaign.ad.duration > 60
      err << I18n.t("bilbos.ads_rotation_error.duration_exceeds_60", name: self.name)
      return err

    elsif new_campaign.minutes.present?
      displays, minutes, ad_duration = new_campaign.imp, new_campaign.minutes, new_campaign.ad.duration
      block_size = ad_duration/10
      needed_blocks = displays* block_size
      current_blocks = minutes*6
      if needed_blocks > current_blocks
        err << I18n.t("bilbos.ads_rotation_error.max_minutes_impressions", number: (current_blocks/block_size).to_i)
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
        if reps > (wm*60/new_campaign.ad.duration).to_i
          err << I18n.t("bilbos.ads_rotation_error.max_hour_impressions", number: (wm*60/new_campaign.ad.duration).to_i)
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
    cps  = self.campaigns.where(provider_campaign: false).select{ |c| c.should_run?(self.id) }.map{ |c| [ c.id, c.board_campaigns.find_by(board: self).remaining_impressions ] }.to_h # { john: 20, david: 26, will:  10} hese are the campaigns and the maximum times that can be displayed in the board
    cycles = []                            # array to store the id's of the bilbo users campaigns the required times
    cps.each do |name, value|              # Fill the cycles array
       value.times do                      # with the id's of the
           cycles << name                  # bilbo users campaigns
       end
    end

    # Check the current time to start placing the ads from
    # current index at first, so we can maximize the earnings
    st = Time.parse(self.start_time.strftime("%H:%M"))
    et = Time.parse(self.end_time.strftime("%H:%M"))
    ct = Time.parse(Time.zone.now.strftime("%H:%M:%S"))
    et = et+1.day if et<=st
    rotation_key = 0
    if ct.between?(st,et)
      elapsed_secs = ct-st
      rotation_key = (elapsed_secs/10).to_i
    end
    ########################################################

    cycles.shuffle!
    block_size = self.duration/10

    total_placed = 0
    # Place the ads in the array after the rotation key (because are the ones that will be displayed first)
    cycles.each do |name|
      place_index = rotation_key + find_substring_index(output[rotation_key..],["-"]*(block_size))
      if place_index != rotation_key - 1
        place_index = push_to_left(output,place_index)
        output[ place_index...place_index +block_size ] = [name] + ["."]*(block_size - 1)
        total_placed +=1
      else
        break
      end
    end

    cycles = cycles[total_placed..]

    #After placing the ads after the rotation_key position, place the remaining ads at the beginning of the array
    cycles.each do |name|
      place_index = find_substring_index(output[...rotation_key],["-"]*(block_size))
      if place_index != -1
        place_index = push_to_left(output,place_index)
        output[ place_index...place_index +block_size ] = [name] + ["."]*(block_size - 1)
      else
        break
      end
    end

    return output

  end

  def build_ad_rotation(new_campaign = nil)

    err = []
    campaign_names = {}

    t_cycles = total_cycles(start_time, end_time)  #total of cycles of the bilbo
    output = []  #array to store the displays in the correct order

    t_cycles.times do   # Initialize the output
        output << '-'       # array with only bilbo
    end                     # ads

    r_cps_first = self.campaigns.includes(:ad).where(provider_campaign: true, clasification: "budget").select{ |c| c.should_run?(self.id) }
    r_cps = r_cps_first.map{ |c| [ c.id, [(c.budget_per_bilbo/(self.get_cycle_price(c) * c.ad.duration/self.duration)).to_i, (c.ad.duration/10).to_i ]] }.to_h#{p1: 60, p2: 50, p3:  67} #these are the required campaigns of the provider, same as cps
    r_cycles = []
    total_r_cps_spaces = 0

    per_time_cps_first = self.campaigns.includes(:ad).where(provider_campaign: true).where.not(minutes: nil).where.not(imp: nil).to_a.select{ |c| c.should_run?(self.id) }
    per_time_cps = per_time_cps_first.map{ |c| [ c.id,[c.imp, c.minutes, c.ad.duration] ]}.to_h  #Input hash for the x_campaings/y_minutes mode

    h_cps_first = []

    self.campaigns.includes(:ad).where(provider_campaign: true, clasification: "per_hour").select{ |c| c.should_run?(self.id) }.each do |c|
      c.impression_hours.each do |cpn|
        if should_run_hour_campaign_in_board?(cpn)
          h_cps_first.append(cpn)
        end
      end
      campaign_names[c.id] = c.name
    end

    #check if validation with new campaign (OPTIONAL!!)

    if new_campaign.present?
      campaign_names[new_campaign.id] = new_campaign.name
      if new_campaign.minutes.present?
        per_time_cps[new_campaign.id] = [new_campaign.imp, new_campaign.minutes, new_campaign.ad.duration]
        per_time_cps_first.append(new_campaign)
      elsif new_campaign.impression_hours.present?
        new_campaign.impression_hours.each do |c|
          if should_run_hour_campaign_in_board?(c)
            h_cps_first.append(c)
          end
        end
      elsif new_campaign.budget.present?
        r_cps[new_campaign.id] = [(new_campaign.budget_per_bilbo/self.cycle_price).to_i, (new_campaign.ad.duration/10).to_i]
        r_cps_first.append(new_campaign)
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
      name = c.campaign_id.to_s << '/' << idx.to_s
      h_cps_first[idx][:campaign_id] = name
      h_cps[name] = [c.imp,c.start,c.end, c.campaign.ad.duration]
    end
    h_cps = sort_by_min_time(h_cps)

    r_cps.each do |name, displays_block_size|
        displays = displays_block_size[0]
        block_size = displays_block_size[1]
        displays.times do
            r_cycles << [name, block_size]
        end
        total_r_cps_spaces += block_size*displays
    end
    r_cycles = r_cycles.sort_by{|name, block_size| -block_size} #first put the biggest blocks
    if r_cycles.present?
      max_block_size = r_cycles[0][1]
    else
      max_block_size = (self.duration/10).to_i
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
       ad_duration = value[3]
       block_size = ad_duration/10
       fi = (working_minutes(start_time,start_t,true)*6).to_i
       la = (working_minutes(start_time,end_t,true)*6).to_i
       value[1] = fi
       value[2] = la
       index_array = find_free_indexes(output[fi...la],["-"]*(block_size))
       if index_array.length < reps
         id = name.split('/')[0].to_i
         err << I18n.t("bilbos.ads_rotation_error.hour_campaign_space", campaign_name: campaign_names[id],bilbo_name: self.name)
         return err
         break
       end
       reps.times do |rep|
         sample_index = index_array.sample
         #sample_index = push_to_left(output,sample_index,max_block_size)
         index_array.delete(sample_index)
         output[ fi + sample_index ...fi + sample_index +block_size ] = [name] + ["."]*(block_size - 1)
       end
    end
    ################################################################################

    total_h = 0                                 # compute the number of spaces used
    h_cps.each {|name, val| total_h+=val[0]*val[3]/10}    # to know the free spaces remaining

    per_time_cps_cp = Marshal.load(Marshal.dump(per_time_cps))
    per_time_cps_cp = translate_hash(per_time_cps_cp,t_cycles)

    total_p = 0
    per_time_cps_cp.each {|key,value| total_p+=value}

    if total_p + total_h> t_cycles
        err << I18n.t("bilbos.ads_rotation_error.minute_campaign_space", campaign_name: per_time_cps_first.last.name, bilbo_name: self.name)
        return err
    end

    per_time_cps = sort_by_max_repetitions(per_time_cps)

    per_time_cps.each do |name, displays_minutes|
        displays = displays_minutes[0]
        minutes = displays_minutes[1]
        ad_duration = displays_minutes[2]
        block_size = ad_duration/10
        size = minutes*6
        inf = 0
        while inf+size <= t_cycles do
          index_array = find_free_indexes(output[inf...inf+size],["-"]*(block_size))
          if index_array.length<displays
            block_size.times do |index|
              h_start, h_end = find_campaign(output, inf+index)
              next if h_start == -1
              next if !h_cps.keys.include? output[h_start] #means this is other minute campaign, i dont know how to move it
              hour_campaign = output[h_start]
              fi, la, h_ad_duration = h_cps[hour_campaign][1], h_cps[hour_campaign][2], h_cps[hour_campaign][3]
              h_c_blocks = h_ad_duration/10
              output[h_start..h_end] = ["-"]*h_c_blocks #i change this here because some dots of this campaign can be outside my region of interest inf-inf+size, so it can be used for the solution.
              place_index = find_substring_index(output[fi...la],["-"]*(h_c_blocks), (inf-fi...inf+size-fi).to_a)
              if place_index != -1
                #place_index = push_to_left(output,place_index,max_block_size)
                output[ fi + place_index ...fi + place_index + h_c_blocks ] = [hour_campaign] + ["."]*(h_c_blocks - 1)
              else
                output[h_start..h_end] = [hour_campaign]+["-"]*(h_c_blocks-1)
              end
            end #end times
            index_array = find_free_indexes(output[inf...inf+size],["-"]*(block_size))
            if index_array.length<displays
              err << I18n.t("bilbos.ads_rotation_error.minute_campaign_space", campaign_name: per_time_cps_first.find(name).first.name, bilbo_name: self.name)
              return err
            end
          end

          displays.times do |rep|
            sample_index = index_array.sample
            #sample_index = push_to_left(output,sample_index,max_block_size)
            index_array.delete(sample_index)
            output[ inf + sample_index ...inf + sample_index +block_size ] = [name] + ["."]*(block_size - 1)
          end
          inf+=size
        end
    end

    #r_cycles = r_cycles.sort_by{|name, block_size| -block_size} #first put the biggest blocks
    r_cycles.each do |elem|
      name = elem[0]
      block_size = elem[1]
      place_index = find_substring_index(output,["-"]*(block_size))
      if place_index != -1
        place_index = push_to_left(output,place_index,block_size)
        output[ place_index...place_index +block_size ] = [name] + ["."]*(block_size - 1)
      else
        err << I18n.t("bilbos.ads_rotation_error.budget_campaign_space", campaign_name: r_cps_first.last.name, bilbo_name: self.name)
        return err
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
  def find_free_indexes(string, substring)
    iterable = (0..string.count-substring.count+1).to_a
    index_array = []
    skip = 0
    iterable.each do |index|
      if skip > 0
        skip-=1
        next
      end
      if string[index...index+substring.count] == substring
        index_array << index
        skip = substring.count - 1
      end
    end
    return index_array
  end

  def find_substring_index(string, substring, unpermitted_indexes = [])
    indexes = (0..string.count-substring.count+1).to_a
    random_start = indexes.sample
    iterable = indexes[random_start..-1] + indexes[0...random_start]
    iterable.each do |index|
      return index if string[index...index+substring.count] == substring && (index...index+substring.count).to_a & unpermitted_indexes == []
    end
    return -1
  end

def sort_by_max_repetitions(hash)
    hash.sort_by {|key, value| -value[0]/value[1]}
    return hash
end
def sort_by_min_time(hash)
    hash.sort_by {|key, value| working_minutes(value[1],value[2])}
    return hash
end

def find_campaign(array, index)
  return -1, -1 if array[index] == "-"
  if array[index] == "."
    index2 =index -1
    while array[index2] == "." do index2-=1 end
    return index2, index
  end
  index2 =index + 1
  while array[index2] == "." do index2+=1 end
  return index, index2-1
end

def translate_hash(per_time_cps,t_cycles)

    per_time_cps.each do |name, displays_minutes|      #Translate the per_time_cps format
        displays = displays_minutes[0]                  #to make it similar to the cps and r_cps
        minutes = displays_minutes[1]
        ad_duration = displays_minutes[2]
        c_blocks = ad_duration/10
        reps = t_cycles/(minutes*6)*(displays*c_blocks)
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
def push_to_left(output,idx,block_size = self.duration/10)
  #If there isn't enough space for a campaign in an interval, we'll move the campaigns
  #to the left to fill that space and displace the free spaces to another interval
  space_between_ads= 0
  #Count spaces between the closest ad (to the left) and the index
  while output[idx-space_between_ads-1] == '-' && idx-space_between_ads-1>=0
    space_between_ads+=1
  end
  idx = idx-space_between_ads%block_size
  return idx
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
  cst = get_time(c.start)
  if et<st
    et+=1.day
    cst += 1.day if cst<st
  end
  return cst.between?(st,et)
end
def valid_end(brd,c)
  st = get_time(brd.start_time)
  et = get_time(brd.end_time)
  return true if et == st
  cst = get_time(c.start)
  cet = get_time(c.end)
  if et<st
    et+=1.day
    cet += 1.day if cet<st
  end
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
