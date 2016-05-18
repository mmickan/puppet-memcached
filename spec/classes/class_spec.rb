require 'spec_helper'

supported_os_list = [
  { 'fam' => 'Debian', 'name' => 'Ubuntu', 'rel' => '14.04' },
  { 'fam' => 'Debian', 'name' => 'Ubuntu', 'rel' => '16.04' },
  { 'fam' => 'Debian', 'name' => 'Debian', 'rel' => '7.0' },
  { 'fam' => 'Debian', 'name' => 'Debian', 'rel' => '8.0' },
]

describe 'memcached', :type => :class do
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

    describe "on supported os #{os['name']}-#{os['rel']}" do

      context 'with default settings' do
        it { should contain_package('memcached').with_ensure('present') }
        it { should contain_user('memcached').with_ensure('present') }
        it { should contain_group('memcached').with_ensure('present') }
        it { should contain_file('/var/log/memcached') }
        it { should contain_memcached__instance('default') }
        it { should_not contain_exec('stop default memcache') }
        it { should contain_file('/etc/default/memcached') }
        it { should contain_service('memcached').with_enable(false) }
      end

      context 'with service_manage = false' do
        let :params do
          { :service_manage => false }
        end

        it { should_not contain_file('/lib/systemd/system/memcached@.service') }
        it { should_not contain_exec('memcached-systemd-reload') }
      end

      context 'with user_manage = false' do
        let :params do
          { :user_manage => false }
        end

        it { should_not contain_user('memcached').with_ensure('present') }
      end

      context 'with group_manage = false' do
        let :params do
          { :group_manage => false }
        end

        it { should_not contain_group('memcached').with_ensure('present') }
      end

      context 'with custom user and group' do
        let :params do
          { :user => 'custom', :group => 'custom' }
        end

        it { should_not contain_user('memcached') }
        it { should_not contain_group('memcached') }
        it { should contain_user('custom') }
        it { should contain_group('custom') }
      end

      context 'with dev package' do
        let :params do
          { :install_dev => true }
        end

        it { should contain_package('libmemcached-dev') }
      end

      context 'without default_instance' do
        let :params do
          { :default_instance => false }
        end

        it { should_not contain_memcached__instance('default') }
      end

      context 'with specific init_style' do
        let :params do
          { :init_style => 'systemd' }
        end

        it { should contain_file('/lib/systemd/system/memcached@.service') }
        it { should contain_exec('memcached-systemd-reload') }
      end

      context 'with invalid service_restart parameter' do
        let :params do
          { :service_restart => 1 }
        end

        it { should_not compile }
      end

      context 'with invalid service_manage parameter' do
        let :params do
          { :service_manage => 1 }
        end

        it { should_not compile }
      end

      context 'with invalid install_dev parameter' do
        let :params do
          { :install_dev => 1 }
        end

        it { should_not compile }
      end

      context 'with invalid default_instance parameter' do
        let :params do
          { :default_instance => 1 }
        end

        it { should_not compile }
      end

      context 'with invalid init_style parameter' do
        let :params do
          { :init_style => 'bogus' }
        end

        it { should_not compile }
      end
    end
  end
end

# vim: expandtab shiftwidth=2 softtabstop=2
