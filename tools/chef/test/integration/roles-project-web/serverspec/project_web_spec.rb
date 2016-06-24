require 'serverspec'
require 'net/http'

set :backend, :exec

describe 'project web role' do
  describe package('git') do
    it { should be_installed }
  end

  describe php_config('date.timezone') do
    it { should eq 'Europe/London' }
  end
end
