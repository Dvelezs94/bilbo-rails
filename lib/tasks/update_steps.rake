namespace :update_steps do
  desc "Update boards no smart to work with steps"
#bilbo run rails update_steps:do_it
  task :do_it => :environment do |t,args|
    Board.where(smart: false).each do |b|
      b.update(steps: true)
      p "#{b.name} updated"
    end
    p "The boards has been updated to steps"
  end
end
