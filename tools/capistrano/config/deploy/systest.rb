set :domain, 'systest_domain.example.com'
set :deploy_to, "/var/www/#{domain}"
set :branch, "develop"
set :keep_releases, 5

server "user@#{domain}", :app, :primary => true
# set :gateway, "user@host" # Use if you need to bounce through another server
