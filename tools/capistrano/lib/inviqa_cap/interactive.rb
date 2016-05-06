require 'capistrano'

module InviqaCap
  class Interactive
    def self.load_into(config)
      config.load do
        set :local_user, 'Unknown'
        set :comment, ''
        set :is_production_deploy, false
        set :is_interactive, true

        namespace :inviqa do
          namespace :interactive do
            # Set the deployment branch interactively
            task :set_deploy_branch do
              set :branch, InviqaCap::Interactive.branch_to_deploy(branch) if is_interactive
            end

            # Get the username of the local user who is running capistrano
            task :set_local_user do
              set(:local_user) do
                run_locally 'whoami'.strip
              end
            end

            # Ask for a comment regarding the deployment, to aide in choosing environments.
            task :set_comment do
              if is_interactive && !is_production_deploy
                set(:comment) do
                  comment = Capistrano::CLI.ui.ask <<-QUESTION
Please add a short comment. For example, how long do you need the environment for:
                  QUESTION
                  comment.strip
                end
                fetch(:comment)
              end
            end

            desc 'Add deployed branch name and comment to branch.json in deployed site.'
            task :tag_deployment_with_branch, roles: :app do
              deployment_details = {
                branch: branch,
                comment: comment,
                deployed_by: local_user
              }

              require 'json'
              json_text = deployment_details.to_json

              run "echo '#{json_text}' > #{latest_release}/branch.json"
            end

            # Confirm that the user actually wanted to run tasks on or deploy to production.
            task :confirm_production_deploy do
              if is_production_deploy
                set(:confirmed) do
                  puts <<-WARN
==============================================================
  WARNING: You're about to perform actions on production.
  Please confirm that your intentions are kind and friendly.
==============================================================
                  WARN
                  answer = Capistrano::CLI.ui.ask '  Are you sure you want to continue? (Y/[N]) '
                  answer.casecmp('y') == 0
                end

                unless fetch(:confirmed)
                  puts "\nDeploy cancelled!"
                  exit
                end
              end
            end
          end
        end

        before 'deploy', 'inviqa:interactive:set_deploy_branch'
        before 'deploy', 'inviqa:interactive:set_local_user'
        before 'deploy', 'inviqa:interactive:set_comment'
        before 'deploy', 'inviqa:interactive:confirm_production_deploy'
      end
    end

    def self.naturalize(s)
      s.scan(/[^\d\.]+|[\d]+/).collect { |f| f =~ /\d+/ ? f.to_i : f }
    end

    def self.natural_cmp(a, b)
      (naturalize a) <=> (naturalize b)
    end

    def self.last_release_branch?
      release_branches = `git show-ref | grep --color=never '/remotes/.*/release/' | awk '{print $2;}'`
      branch = release_branches.split("\n").sort { |a, b| natural_cmp a, b }.last.to_s
      branch
    end

    def self.confirmed_branch?(branch)
      print "  Choose a branch to deploy [#{branch}]: "
      confirmation = $stdin.gets.strip!
      branch = confirmation unless confirmation.empty?
      branch
    end

    def self.branch_to_deploy(default_branch = '')
      branch = default_branch
      branch = last_release_branch? if !branch || branch == ''
      branch = 'master' if branch.empty?

      confirmed_branch?(branch)
    end
  end
end

if Capistrano::Configuration.instance
  InviqaCap::Interactive.load_into(Capistrano::Configuration.instance)
end
