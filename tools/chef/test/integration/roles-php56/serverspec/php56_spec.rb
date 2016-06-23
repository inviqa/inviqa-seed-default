require 'serverspec'
require 'net/http'

set :backend, :exec

describe 'php56 role' do
  [
    "php56w",
    "php56w-bcmath",
    "php56w-devel",
    "php56w-fpm",
    "php56w-gd",
    "php56w-mbstring",
    "php56w-mcrypt",
    "php56w-mysqlnd",
    "php56w-opcache",
    "php56w-pdo",
    "php56w-pecl-apcu",
    "php56w-pecl-imagick",
    "php56w-pecl-memcache",
    "php56w-pecl-redis",
    "php56w-soap",
    "php56w-xml",
    "php56w-xmlrpc"
  ].each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end

  describe command('php -v') do
    its(:stdout) { should match /PHP 5\.6/ }
  end
end
