set :stages, %w(dev int uat systest production)
set :default_stage, "dev"

require 'capistrano/ext/multistage'
require 'inviqa_cap/composer'
require 'inviqa_cap/interactive'
require 'inviqa_cap/notify_slack'
require 'inviqa_cap/notify_newrelic'

set :repository, "{{git_url}}"
set :scm, :git
set :user, "deploy"
set :deploy_via, :remote_cache
set :use_sudo, false
set :keep_releases, 5

set :linked_files, [ ]
set :linked_directories, [ ]

# Slack notifications
set :domain, '{{hostname}}'
set :slack_channel, '#{{name}}'
set :github_url, 'https://github.com/{{git_url}}'.gsub!('git@github.com:', '')
set :jira_url, 'https://jira.example.com/'
set :jira_project, '\\(PROJECT1|PROJECT2|PROJECT3\\)' # regular expression!
set :slack_hook_url, 'https://hooks.slack.com/services/.../.../...'
# Notify the development team about this release?
set :notify_development, false
# End Slack notifications

after "deploy:finalize_update", "deploy:cleanup"
