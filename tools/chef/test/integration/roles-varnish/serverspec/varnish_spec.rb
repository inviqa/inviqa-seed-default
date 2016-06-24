require 'serverspec'
require 'net/http'

set :backend, :exec

describe 'varnish role' do
  describe process('varnish') do
    its(:user) { should eq 'varnish' }
  end

  describe service('varnish') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/etc/varnish/default.vcl') do
    it { should exist }
    its(:owner) { should eq 'varnish' }
    its(:group) { should eq 'varnish' }
    its(:content) { should match /\.host = "127.0.0.1";/ }
    its(:content) { should match /\.port = "8080";/ }
  end
end
