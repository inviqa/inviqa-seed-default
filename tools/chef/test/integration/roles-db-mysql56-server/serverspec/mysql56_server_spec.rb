require 'serverspec'
require 'net/http'

set :backend, :exec

describe 'mysql56 server role' do
  [
    "Percona-Server-shared-56",
    "Percona-Server-server-56",
    "Percona-Server-devel-56"
  ].each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end

  [
    "mysql-libs",
    "mysql55",
    "mysql55-libs",
    "mysql-server",
    "mysql"
  ].each do |pkg|
    describe package(pkg) do
      it { should_not be_installed }
    end
  end

  describe process('mysqld') do
    it { should be_running }
    its(:user) { should eq 'mysql' }
  end

  describe service('mysql'), :if => os[:release] =~ /^7\./ do
    it { should be_running.under('systemd') }
    it { should be_enabled }
  end

  describe service('mysqld'), :if => os[:release] =~ /^6\./ do
    it { should be_running }
    it { should be_enabled }
  end
end
