# == Class: memcached::params
#
class memcached::params {
  case $::osfamily {
    'Debian': {
      $package_name      = 'memcached'
      $package_provider  = undef
      $dev_package_name  = 'libmemcached-dev'
      $config_tmpl       = "${module_name}/memcached.conf.erb"
      $user              = 'memcached'
      $group             = 'memcached'
      $logfile           = '/var/log/memcached/memcached.log'
    }
    default: {
      fail("Unsupported platform: ${::osfamily}/${::operatingsystem}")
    }
  }

  case $::operatingsystem {
    'Ubuntu': {
      if versioncmp($::operatingsystemrelease, '15.10') < 0 {
        $init_style = 'debian'
      } else {
        $init_style = 'systemd'
      }
    }
    'Debian': {
      if versioncmp($::operatingsystemrelease, '8.0') < 0 {
        $init_style = 'debian'
      } else {
        $init_style = 'systemd'
      }
    }
    default: {
      fail('Unsupported OS')
    }
  }

}
