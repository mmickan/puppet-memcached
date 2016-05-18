require 'spec_helper'

supported_os_list = [
  { 'fam' => 'Debian', 'name' => 'Ubuntu', 'rel' => '14.04', 'init' => 'debian' },
  { 'fam' => 'Debian', 'name' => 'Ubuntu', 'rel' => '16.04', 'init' => 'systemd' },
  { 'fam' => 'Debian', 'name' => 'Debian', 'rel' => '7.0', 'init' => 'debian' },
  { 'fam' => 'Debian', 'name' => 'Debian', 'rel' => '8.0', 'init' => 'systemd' },
]

describe 'memcached', :type => :class do
  supported_os_list.each do |os|
    describe "on supported os #{os['name']}-#{os['rel']}" do
      let :facts do
        {
          :osfamily => os['fam'],
          :operatingsystem => os['name'],
          :operatingsystemrelease => os['rel'],
          :memorysize => '1000 MB',
          :processorcount => '1',
        }
      end

      context 'with default settings' do
        it { should contain_class('memcached').with_init_style(os['init']) }
      end

    end
  end
end
