namespace :calculate_provider_impressions_and_board_prices do
  desc "Setea el precio de todos los boards y las impresiones calculando el precio que se dara a los proveedores"
  task :run => :environment do
    p "=== Empezando a actualizar boards"
    Board.all.each do |board|
      begin
        current_base_earnings = board.base_earnings
        new_base_earnings = board.base_earnings * 1.25
        board.update_columns(provider_earnings: current_base_earnings, base_earnings: new_base_earnings)
      rescue
        "Error al actualizar el board #{board.name}"
      end
    end
    p "Se han terminado de actualizar los boards"

    p "=== Empezando a actualizar impresiones"
    Impression.all.each do |imp|
      begin
        imp.update_columns(provider_price: (imp.total_price * 0.80).round(3))
      rescue => e
        p "Error al actualizar impresion #{imp.id}"
        p e
      end
    end
    p "Se han terminado de actualizar todaslas impresiones"
    p "Tarea finalizada."
  end
end
