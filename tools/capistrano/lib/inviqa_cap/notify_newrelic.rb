#!/usr/bin/env ruby
# encoding: utf-8

require 'capistrano'

module InviqaCap
  class NotifyNewrelic
    def self.load_into(config)
      config.load do
        set :new_relic_api_key, ''

        after 'deploy', 'inviqa:notifications:notify_newrelic'

        namespace :inviqa do
          namespace :notifications do
            task :notify_newrelic, except: { no_release: true } do
              if exists?(:new_relic_api_key) && exists?(:new_relic_application_id)
                require 'shellwords'
                escaped_branch = Shellwords.escape(branch)
                escaped_user = Shellwords.escape(local_user)
                run "curl -H 'x-api-key:#{new_relic_api_key}'"\
                    " -d 'deployment[application_id]=#{new_relic_application_id}'"\
                    " -d 'deployment[description]=#{escaped_branch}'"\
                    " -d 'deployment[revision]=#{real_revision[0, 7]}'"\
                    " -d 'deployment[user]=#{escaped_user}'"\
                    " https://api.newrelic.com/deployments.xml"
              else
                puts "No New Relic API configuration found. Deployment event NOT sent."
              end
            end
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  InviqaCap::NotifyNewrelic.load_into(Capistrano::Configuration.instance)
end
