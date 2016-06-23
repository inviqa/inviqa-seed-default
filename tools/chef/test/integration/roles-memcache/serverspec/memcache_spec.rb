require 'serverspec'
require 'net/http'

set :backend, :exec

describe 'memcache role' do
  describe package('memcached') do
    it { should be_installed }
  end

  describe process('memcached') do
    it { should be_running }
    its(:user) { should eq 'memcached' }
  end

  describe service('memcached'), :if => os[:release] =~ /^7\./ do
    it { should be_running.under('systemd') }
    it { should be_enabled }
  end

  describe service('memcached'), :if => os[:release] =~ /^6\./ do
    it { should be_running }
    it { should be_enabled }
  end
end
