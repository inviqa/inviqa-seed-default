require 'serverspec'
require 'net/http'

set :backend, :exec

describe 'solr role' do
  describe process('java') do
    its(:user) { should eq 'jetty' }
  end

  describe service('jetty') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/usr/share/jetty/webapps/solr.war') do
    it { should exist }
  end
end
