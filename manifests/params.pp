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
}
