namespace :admin_email do
  desc "This create an admin user"
#bilbo run rails admin_email:do_it["email","name"]
  task :do_it, [:email,:name] => :environment do |t,args|
    puts args[:email]
     User.invite!(email: args[:email], role: "admin", name: args[:name])
  end
end
