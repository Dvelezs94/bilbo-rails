namespace :update_utc_offset do
  desc "Update utc_offset of boards due to the timezone changes"
#bilbo run rails update_utc_offset:do_it[value]
  task :do_it, [:value] => :environment do |t,args|
    mins = args[:value].to_i
    p "Adding #{mins} minutes to the utc_offset of every board"
    Board.all.each do |b|
      b.update(utc_offset: b.utc_offset + mins)
    end
    p "The utc_offset of all boards has been updated"
  end
end
