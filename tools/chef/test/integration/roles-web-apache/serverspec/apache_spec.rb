require 'serverspec'
require 'net/http'

set :backend, :exec

describe 'apache role' do
  describe process('httpd') do
    its(:user) { should eq 'apache' }
  end

  describe service('httpd') do
    it { should be_enabled }
    it { should be_running }
  end

  describe command('httpd -M') do
    its(:output) { should match 'php5_module' }
    its(:output) { should match 'rewrite_module' }
    its(:output) { should match 'ssl_module' }
    its(:output) { should match 'deflate_module' }
    its(:output) { should match 'expires_module' }
    its(:output) { should match 'headers_module' }
    its(:output) { should match 'realdoc_module' }
  end
end
