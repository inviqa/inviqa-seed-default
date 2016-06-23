require 'serverspec'
require 'net/http'

set :backend, :exec

describe 'base role' do
  describe package('ntpd') do
    it { should be_installed }
  end

  describe process('ntpd') do
    it { should be_running }
    its(:user) { should eq 'ntp' }
  end

  describe service('ntpd'), :if => os[:release] =~ /^7\./ do
    it { should be_running.under('systemd') }
    it { should be_enabled }
  end

  describe service('ntpd'), :if => os[:release] =~ /^6\./ do
    it { should be_running }
    it { should be_enabled }
  end

  describe command('date +%Z') do
    its(:stdout) { should eq 'UTC' }
  end
end
