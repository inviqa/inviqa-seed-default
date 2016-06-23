require 'serverspec'
require 'net/http'

set :backend, :exec

describe 'php56-development role' do
  describe package('php56w-pecl-xdebug') do
    it { should be_installed }
  end

  describe command('php -v') do
    its(:stdout) { should match /PHP 5\.6/ }
    its(:stdout) { should match /with Xdebug/ }
  end
end
