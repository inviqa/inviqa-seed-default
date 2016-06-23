require 'serverspec'
require 'net/http'

set :backend, :exec

describe 'mysql56 client role' do
  [
    "Percona-Server-shared-56",
    "Percona-Server-client-56",
    "Percona-Server-devel-56"
  ].each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end

  [
    "mysql-libs",
    "mysql55",
    "mysql55-libs"
  ].each do |pkg|
    describe package(pkg) do
      it { should_not be_installed }
    end
  end
end
