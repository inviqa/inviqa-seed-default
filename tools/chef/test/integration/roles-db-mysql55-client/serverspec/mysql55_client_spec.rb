require 'serverspec'
require 'net/http'

set :backend, :exec

describe 'mysql55 client role' do
  [
    "mysql55-libs",
    "mysqlclient16",
    "mysql55"
  ].each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end

  [
    "mysql-libs",
    "mysql55-server"
  ].each do |pkg|
    describe package(pkg) do
      it { should_not be_installed }
    end
  end
end
