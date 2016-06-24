require 'serverspec'
require 'net/http'

set :backend, :exec

describe 'nginx role' do
  describe process('nginx') do
    its(:user) { should eq 'nginx' }
  end

  describe process('php-fpm') do
    its(:user) { should eq 'nginx' }
  end

  describe package('nginx18') do
    it { should be_installed }
  end

  describe service('nginx') do
    it { should be_enabled }
    it { should be_running }
  end

  describe service('php-fpm') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/etc/php-fpm.d/www.conf') do
    its(:content) { should match %r{php_value\[error_log\] = /var/log/php-fpm/www-error.log} }
    its(:content) { should match %r{php_value\[session\.save_path\] = /var/lib/php/session} }
    its(:content) { should match %r{php_flag\[log_errors\] = On} }
  end
end
