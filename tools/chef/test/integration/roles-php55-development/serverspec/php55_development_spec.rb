require 'serverspec'
require 'net/http'

set :backend, :exec

describe 'php55-development role' do
  describe package('php55w-pecl-xdebug') do
    it { should be_installed }
  end

  describe command('php -v') do
    its(:stdout) { should match /PHP 5\.5/ }
    its(:stdout) { should match /with Xdebug/ }
  end
end
