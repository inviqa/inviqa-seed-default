require 'serverspec'
require 'net/http'

set :backend, :exec

describe 'project development role' do
  describe package('yum-cron') do
    it { should be_installed }
  end

  describe service('yum-cron') do
    it { should be_enabled }
    it { should be_running }
  end

  it 'allows port 1080 to be communicated with' do
    expect(iptables).to have_rule('-p tcp -m tcp --dport 1080 -j RETURN').with_chain('STANDARD-FIREWALL')
  end
end
