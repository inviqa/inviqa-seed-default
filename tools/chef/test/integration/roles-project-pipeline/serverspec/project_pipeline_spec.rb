require 'serverspec'
require 'net/http'

set :backend, :exec

describe 'project pipeline role' do
  describe package('yum-cron') do
    it { should be_installed }
  end

  describe service('yum-cron') do
    it { should be_enabled }
    it { should be_running }
  end
end
