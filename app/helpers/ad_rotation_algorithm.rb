module AdRotationAlgorithm
  extend ActiveSupport::Concern

  def build_ad_rotation
    #Primero cps se llena con todas las campañas no obligatorias, cada una está las veces que puede imprimirse.
    #lo mismo con r_cps con las campañas del proveedor obligatorias
    #Si el arreglo resultante no llena el tiempo total , relleno el espacio restante con "-", indicando que no hay campaña
    # Si el arreglo sobrepasa el tiempo disponible, borro aleatoriamente tantas veces como sea necesario hasta tener el tamaño adecuado al tiempo
    #Los ordeno aleatoriamente
    #despues reviso si hay consecutivos iguales y trato de cambiarlos de lugar (incluidos los separadores, esto ayuda a una distribución del tiempo al aire más homogénea)
    hours = self.working_hours
    total_cycles = hours*60*6.to_i #each hour has 60 minutes, each with 6 cycles, integer because i cant have medium cycle
    cps  = self.campaigns.where(provider_campaign: false).to_a.select(&:should_run?).map{ |c| [ c.id, (c.budget_per_bilbo/self.cycle_price).to_i ] }.to_h # { john: 20, david: 26, will:  10} hese are the campaigns and the maximum times that can be displayed in the board
    r_cps = self.campaigns.where(provider_campaign: true).to_a.select(&:should_run?).map{ |c| [ c.id, (c.budget_per_bilbo/self.cycle_price).to_i ] }.to_h#{p1: 60, p2: 50, p3:  67} #these are the required campaigns of the provider, same as cps
    cycles = [] #empty and fill it with total displays in order
    r_cycles = [] #same as cycles
    r_cps.map do |name, displays| #each of the provider required cycles
      displays.times { r_cycles << name }
    end
    cps.map do |name, displays| #each of bilbo  cycles
      displays.times { cycles << name }
    end

    #check if empty cycles or more cycles
    if cycles.length+r_cycles.length < total_cycles #if empty cycles, add them
      empty_cycles = total_cycles - (cycles.length+r_cycles.length)
      cycles.fill("-", cycles.length, empty_cycles)
    elsif (cycles.length+r_cycles.length) > total_cycles
      extra_cycles = (cycles.length+r_cycles.length) - total_cycles
      extra_cycles.round(0).times do
        cycles.delete_at(rand(cycles.length))
      end
    end
    #join the required with the other cycles
    cycles+=r_cycles #this joins cycles and r_cycles
    if cycles.length > total_cycles
        puts("El proveedor se excedio con el tiempo en sus campanas")
    end
    cycles.shuffle!
    #now try to change the same consecutive campaigns
    cycles.each_with_index do |cycle, index|
      index2 = index+1
      cycle2 = cycles[index2]
      if cycle == cycle2 # if consecutive campaigns are the same
        #i am going to check if other campaign fits in that place
        cycles.each_with_index do |cycle3, index3|
          if cycle3 != cycle2 && cycles[index3-1] != cycle2 && cycles[index3+1] != cycle2 && cycles[index2+1] != cycle3  #swap variables if this fits to not be equal
            cycles[index2],cycles[index3] = cycle3,cycle2
            break
          end
        end
      end
    end
    return cycles
  end
end
