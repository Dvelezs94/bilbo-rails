namespace :admin_email do
  desc "This create an admin user"
#bilbo run rails admin_email:do_it["email"]
  task :do_it, [:email] => :environment do |t,args|
    puts args[:email]
     User.invite!(email: args[:email].tr('"', ''), role: "admin")
  end
end
