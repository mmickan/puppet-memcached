#
# == Define: memcached::instance
#
# Deploy and manage an instance of memcached.
#
# === Parameters
#
# [*tcp_port*]
#   The TCP port on which the memcached instance will listen.
#
# [*udp_port*]
#   The UDP port on which the memcached instance will listen.
#
# [*unix_socket*]
#   The unix socket on which the memcached instance will listen.
#
# [*logfile*]
#   Logfile for this memcached instance.
#
# [*pidfile*]
#   Pidfile for this memcached instance, or undef to skip creating a
#   pidfile.
#
# [*max_memory*]
#   Integer with optional '%' suffix.  Maximum memory (in megabytes or as a
#   percentage of total memory) this memcached instance should use.
#   Defaults to 95% of total memory.  Use a '%' suffix if specifying a
#   percentage.
#
# [*item_size*]
#   Integer.  The default size (in megabytes) of each slab page for this
#   memcache instance.  The default is undef, meaning memcached will use its
#   default size.
#
# [*lock_memory*]
#   Boolean.  When true, this locks down all paged memory.  Note that this
#   is a somewhat dangerous option with large caches - consult the memcached
#   homepage for configuration suggestions.
#
# [*user*]
#   The user to run this memcached instance as.  Note that this module does
#   not create the user.
#
# [*large_mem_pages*]
#   Boolean.  Try to use large memory pages (if available) for this
#   memcached instance.
#
# [*processorcount*]
#   Integer.  Number of threads to use to process incoming requests.
#   Defaults to the number of CPUs.
#
# [*auto_removal*]
#   Boolean.  Set to true to _disable_ automatic removal of items from the
#   cache when out of memory.  Note that with this set to true, additions to
#   a full cache will not be possible until adequate space is freed up.
#
# [*verbosity*]
#   Set to undef to make this memcached instance quiet.  Set to "v" to print
#   out errors and warnings during the event loop, or "vv" to also print
#   client commands and responses.
#
# [*listen_ip*]
#   IP address on which this memcached instance will listen.
#
# [*max_connections*]
#   Integer.  Allow this many simultaneous connections for this memcached
#   instance.
#
# === Example usage
#
#  memcached::instance { '11211': }
#
define memcached::instance(
  $tcp_port        = $name,
  $udp_port        = $name,
  $unix_socket     = undef,
  $logfile         = "/var/log/memcached_${name}.log",
  $pidfile         = "/var/run/memcached_${name}.pid",
  $max_memory      = $::memcached::max_memory,
  $item_size       = $::memcached::item_size,
  $lock_memory     = $::memcached::lock_memory,
  $use_sasl        = $::memcached::use_sasl,
  $user            = $::memcached::user,
  $large_mem_pages = $::memcached::large_mem_pages,
  $processorcount  = $::memcached::processorcount,
  $auto_removal    = $::memcached::auto_removal,
  $verbosity       = $::memcached::verbosity,
  $listen_ip       = $::memcached::listen_ip,
  $max_connections = $::memcached::max_connections,
) {

  if $max_memory and !is_integer($max_memory) {
    validate_re($max_memory, '^\d+%$')
  }
  if $item_size and !is_integer($item_size) {
    fail('item_size must be an integer')
  }
  unless is_integer($processorcount) {
    fail('processorcount must be an integer')
  }
  unless is_integer($max_connections) {
    fail('max_connections must be an integer')
  }
  validate_bool($lock_memory)
  validate_bool($use_sasl)
  validate_bool($large_mem_pages)
  validate_bool($auto_removal)
  validate_re($verbosity, ['^v{0,2}$'])
  validate_absolute_path($logfile)
  if $pidfile { validate_absolute_path($pidfile) }
  if $listen_ip != '' and ! is_ip_address($listen_ip) {
    fail('listen_ip must be a valid IP address')
  }

  $_service_name = "memcached_${name}"
  $_config_file  = "/etc/memcached_${name}.conf"

  if $::memcached::service_restart and $::memcached::service_manage {
    $_service_notify = Service[$_service_name]
  } else {
    $_service_notify = undef
  }

  file { $_config_file:
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template($::memcached::params::config_tmpl),
    notify  => $_service_notify,
  }

  if $::memcached::service_manage {
    file { "/etc/init.d/${_service_name}":
      ensure  => 'file',
      content => template('memcached/memcached_init.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
    } ->

    service { $_service_name:
      ensure  => $::memcached::service_ensure,
      enable  => $::memcached::service_enable,
      require => [
        Package[$::memcached::params::package_name],
        File[$_config_file],
      ],
    }
  }

}
