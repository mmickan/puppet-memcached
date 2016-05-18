require 'spec_helper'

supported_os_list = [
  { 'fam' => 'Debian', 'name' => 'Ubuntu', 'rel' => '14.04' },
  { 'fam' => 'Debian', 'name' => 'Ubuntu', 'rel' => '16.04' },
]

describe 'memcached::instance', :type => :define do
  supported_os_list.each do |os|
    let :facts do
      {
        :osfamily => os['fam'],
        :operatingsystem => os['name'],
        :operatingsystemrelease => os['rel'],
        :memorysize => '1000 MB',
        :processorcount => '1',
      }
    end

    let(:pre_condition) {[
      'class { "memcached": default_instance => false }'
    ]}

    let(:title) { '11211' }

    describe "on supported os #{os['name']}-#{os['rel']}" do

      context 'with default parameters' do
        it { should contain_file('/etc/memcached_11211.conf') }
        it { should contain_service('memcached 11211') }
      end

      context 'with init_style = systemd' do
        let(:pre_condition) {[
          'class { "memcached": init_style => systemd }'
        ]}

        it { should contain_exec('memcached-systemd-reload').that_comes_before('Service[memcached 11211]') }
      end

      context 'with init_style = upstart' do
        let(:pre_condition) {[
          'class { "memcached": init_style => upstart }'
        ]}

        pending { should contain_file('/etc/init/memcached_11211.conf') }
        pending { should contain_file('/etc/init.d/memcached_11211').with_ensure('link') }
      end

      context 'with init_style = debian' do
        let(:pre_condition) {[
          'class { "memcached": init_style => debian }'
        ]}

        it { should contain_file('/etc/init.d/memcached_11211').with_ensure(nil) }
        it { should_not contain_exec('memcached-systemd-reload') }
        it { should_not contain_file('/etc/init/memcached_11211.conf') }
      end

      context 'with invalid init_style' do
        let(:pre_condition) {[
          'class { "memcached": init_style => bogus }'
        ]}

        it { should_not compile }
      end

      context 'without service_manage' do
        let(:pre_condition) {[
          'class { "memcached": service_manage => false }'
        ]}

        it { should compile }
        it { should_not contain_exec('memcached-systemd-reload') }
        it { should_not contain_file('/etc/init/memcached_11211.conf') }
        it { should_not contain_file('/etc/init.d/memcached_11211') }
        it { should_not contain_service('memcached 11211') }
      end

      context 'with invalid max_memory' do
        let(:params) do
          { :max_memory => 'one' }
        end

        it { should_not compile }
      end

      context 'with invalid item_size' do
        let(:params) do
          { :item_size => 'one' }
        end

        it { should_not compile }
      end

      context 'with invalid processorcount' do
        let(:params) do
          { :processorcount => 'one' }
        end

        it { should_not compile }
      end

      context 'with invalid max_connections' do
        let(:params) do
          { :max_connections => 'one' }
        end

        it { should_not compile }
      end

      context 'with invalid lock_memory' do
        let(:params) do
          { :lock_memory => 'maybe' }
        end

        it { should_not compile }
      end

      context 'with invalid use_sasl' do
        let(:params) do
          { :use_sasl => 'maybe' }
        end

        it { should_not compile }
      end

      context 'with invalid large_mem_pages' do
        let(:params) do
          { :large_mem_pages => 'maybe' }
        end

        it { should_not compile }
      end

      context 'with invalid auto_removal' do
        let(:params) do
          { :auto_removal => 'maybe' }
        end

        it { should_not compile }
      end

      context 'with invalid verbosity' do
        let(:params) do
          { :verbosity => 'vvv' }
        end

        it { should_not compile }
      end

      context 'with invalid logfile' do
        let(:params) do
          { :logilfe => '../relative/path' }
        end

        it { should_not compile }
      end

      context 'with invalid pidfile' do
        let(:params) do
          { :pidfile => '../relative/path' }
        end

        it { should_not compile }
      end

      context 'with invalid listen_ip' do
        let(:params) do
          { :listen_ip => '256.2.5.6' }
        end

        it { should_not compile }
      end

    end
  end
end
