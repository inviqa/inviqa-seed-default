require 'serverspec'
require 'net/http'

set :backend, :exec

describe 'php55 role' do
  [
    "php55w",
    "php55w-bcmath",
    "php55w-devel",
    "php55w-fpm",
    "php55w-gd",
    "php55w-mbstring",
    "php55w-mcrypt",
    "php55w-mysqlnd",
    "php55w-opcache",
    "php55w-pdo",
    "php55w-pecl-apcu",
    "php55w-pecl-imagick",
    "php55w-pecl-memcache",
    "php55w-pecl-redis",
    "php55w-soap",
    "php55w-xml",
    "php55w-xmlrpc"
  ].each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end

  describe command('php -v') do
    its(:stdout) { should match /PHP 5\.5/ }
  end
end
