require 'serverspec'
require 'net/http'

set :backend, :exec

describe 'redis30 role' do
  describe package('redis30u') do
    it { should be_installed }
  end

  describe process('redis') do
    its(:user) { should eq 'redis' }
  end

  describe service('redis6379') do
    it { should be_enabled }
    it { should be_running }
  end
end
