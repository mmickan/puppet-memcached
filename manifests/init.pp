#
# == Class: memcached
#
# Deploy and manage memcached.  This class sets sensible defaults for all
# parameters.
#
# === Parameters
#
# [*package_ensure*]
#   (present|absent|<version>) Determines whether or not the package will be
#   installed, and what version will be installed.
#
# [*service_manage*]
#   Boolean.  Whether or not Puppet should manage the configured memcached
#   service(s).
#
# [*service_restart*]
#   Boolean.  Whether or not Puppet should restart memcached instances when
#   their configuration is changed.
#
# [*install_dev*]
#   Boolean.  Determines whether or not the development package will be
#   installed.
#
# [*default_instance*]
#   Boolean.  Whether or not to manage a default memcached instance.  The
#   default instance is usually sufficient when only a single memcached
#   instance is required.
#
# See the memcached::instance defined type for an explanation of the
# remaining parameters.
#
# === Example usage
#
# Single instance:
#
#  class { 'memcached': }
#
#
# Multiple instances:
#
#  class { 'memcached': default_instance => false }
#  memcached::instance { '11211': }
#  memcached::instance { '11212': }
#
#
# Mutliple instances with descriptive names:
#
#  class { 'memcached': default_instance => false }
#  memcached::instance { 'sessions':
#    tcp_port => 11211,
#    udp_port => 11211,
#  }
#  memcached::instance { 'muc':
#    tcp_port => 11212,
#    udp_port => 11212,
#  }
#
class memcached (
  $package_ensure   = 'present',
  $service_manage   = true,
  $service_restart  = true,
  $install_dev      = false,
  $default_instance = true,

  # defaults for per-instance settings
  $max_memory       = undef,
  $item_size        = undef,
  $lock_memory      = false,
  $use_sasl         = false,
  $user             = $::memcached::params::user,
  $large_mem_pages  = false,
  $processorcount   = $::processorcount,
  $auto_removal     = false,
  $verbosity        = undef,
  $listen_ip        = '0.0.0.0',
  $max_connections  = '8192',
) inherits memcached::params {

  validate_bool($service_restart)
  validate_bool($service_manage)
  validate_bool($install_dev)
  validate_bool($default_instance)

  if $package_ensure == 'absent' {
    $service_ensure = 'stopped'
    $service_enable = false
  } else {
    $service_ensure = 'running'
    $service_enable = true
  }

  package { $memcached::params::package_name:
    ensure   => $package_ensure,
    provider => $memcached::params::package_provider
  }

  if $install_dev {
    package { $memcached::params::dev_package_name:
      ensure  => $package_ensure,
      require => Package[$memcached::params::package_name]
    }
  }

  if $default_instance {
    memcached::instance { 'default':
      tcp_port     => 11211,
      udp_port     => 11211,
      logfile      => $::memcached::params::logfile,
      pidfile      => '/var/run/memcached.pid',
    }
  }

  file { '/etc/default/memcached':
    ensure => 'file',
    source => 'puppet:///modules/memcached/memcached_default',
  }

  # in a multi-instance memcached configuration, this service starts all
  # memcached instances.  However, we start them individually and don't want
  # to attempt to start them twice so we disable this service on boot and
  # don't do anything else with it
  service { 'memcached':
    ensure  => undef,
    enable  => false,
    require => Package[$::memcached::params::package_name],
  }

}
