set :domain, 'www.example.com'
set :deploy_to, "/var/www/#{domain}"
set :branch, "master"
set :keep_releases, 5
set :is_production_deploy, true
set :new_relic_application_id, ''

server "user@#{domain}", :app, :primary => true
# set :gateway, "user@host" # Use if you need to bounce through another server
