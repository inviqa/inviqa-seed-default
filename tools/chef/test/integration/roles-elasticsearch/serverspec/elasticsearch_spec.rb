require 'serverspec'
require 'net/http'

set :backend, :exec

describe 'elasticsearch role' do
  describe process('java') do
    it { should be_running }
    its(:user) { should eq 'elasticsearch' }
    its(:args) { should match %r{-Des\.config=/usr/local/etc/elasticsearch/elasticsearch\.yml} }
  end

  describe service('elasticsearch'), :if => os[:release] =~ /^7\./ do
    it { should be_running.under('systemd') }
    it { should be_enabled }
  end

  describe service('elasticsearch'), :if => os[:release] =~ /^6\./ do
    it { should be_running }
    it { should be_enabled }
  end
end
