#!/usr/bin/env ruby
# encoding: utf-8

require 'capistrano'

module InviqaCap
  class NotifySlack
    def self.load_into(config)
      config.load do
        set :domain, 'example.com'
        set :slack_channel, '#general'
        set :github_url, 'https://github.com/inviqa/hem-seed-default'
        set :jira_url, 'https://example.com/'
        set :jira_project, '\\(PROJECT1|PROJECT2|PROJECT3\\)' # regular expression!

        set :slack_hook_url, 'https://hooks.slack.com/services/.../.../...'

        # Notify the development team about this release?
        set :notify_development, false

        after 'deploy', 'inviqa:notifications:notify_slack'

        namespace :inviqa do
          namespace :notifications do
            task :notify_slack, except: { no_release: true } do
              if notify_development
                puts 'Notifying Slack:'

                authors = ''
                if previous_revision
                  authors = capture(
                    "cd #{shared_path}/cached-copy && git log #{previous_revision[0, 7]}..#{current_revision[0, 7]}"\
                    ' --format=\"%aN\" | sort | uniq',
                    hosts: [roles[:app].servers.first]
                  )
                end

                contributors = ''
                authors.each_line do |line|
                  line.delete!('";')
                  line.strip!
                  line.gsub!("'", '\u0027')
                  contributors = "#{contributors}, #{line}"
                end

                if contributors.to_s == ''
                  contributors = 'None'
                else
                  contributors[0] = ''
                end

                log = ''
                if previous_revision
                  log = capture(
                    "cd #{shared_path}/cached-copy && git log #{previous_revision[0, 7]}..#{current_revision[0, 7]}"\
                    " --format=\"%s\" | grep -oh '#{jira_project}-[0-9]\\+' | sort | uniq",
                    hosts: [roles[:app].servers.first]
                  )
                end

                tickets = ''
                log.each_line do |line|
                  line.delete!('";')
                  line.strip!
                  line.gsub!("'", '\u0027')
                  tickets = "#{tickets}, <#{jira_url}/#{line}|#{line}>"
                end

                if tickets.to_s == ''
                  tickets = 'None'
                else
                  tickets[0] = ''
                end

                replaced_revision = ''
                compare_link = ''
                if previous_revision
                  replaced_revision = " (replacing #{previous_revision[0, 7]})"
                  compare_link = "(<#{github_url}/compare/#{previous_revision[0, 7]}..."\
                                 "#{current_revision[0, 7]}|View Changes>)"
                end

                json_payload = {
                  channel: slack_channel,
                  text: "Deployment to <https://#{domain}> complete",
                  attachments: [
                    {
                      fallback: "Deployed revision #{current_revision[0, 7]} from branch #{branch}#{replaced_revision}",
                      color: '#45B5D2',
                      fields: [
                        {
                          title: 'Branch Deployed',
                          value: "<#{github_url}/tree/#{branch}|#{branch}>",
                          short: true
                        },
                        {
                          title: 'Revision',
                          value: "<#{github_url}/commits/#{current_revision}|#{current_revision[0, 7]}>#{compare_link}",
                          short: true
                        }
                      ]
                    }
                  ]
                }

                json_payload[:attachments][0][:fields] << {
                  title: 'Deployed By',
                  value: local_user,
                  short: true
                } if local_user

                json_payload[:attachments][0][:fields] << {
                  title: 'Comment',
                  value: comment,
                  short: false
                } if comment

                json_payload[:attachments][0][:fields] << {
                  title: 'Contributors',
                  value: contributors,
                  short: false
                }
                json_payload[:attachments][0][:fields] << {
                  title: 'Tickets',
                  value: tickets,
                  short: false
                }

                require 'json'
                json_text = json_payload.to_json

                run_locally "curl -X POST --data 'payload=#{json_text}' #{slack_hook_url}"
              else
                puts 'Skipping Slack Notification'
              end
            end
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  InviqaCap::NotifySlack.load_into(Capistrano::Configuration.instance)
end
