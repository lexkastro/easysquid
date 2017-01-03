# It doesn't use fragments to concatenate config file
# instead, it uses a unique template to provide
# whole configuration. 
# Use this approach if you just want an easy 
# deployment where you preffer to manage
# ACL's and some configuration directly in
# your VCS in a single source.
class custom_configuration {


  $http_port              = '8080'
  $cache_path             = '/var/spool/squid'
  $cache_size_mb          = '128'
  $cache_l1               = '16'
  $cache_l2               = '256'
  $coredump_dir           = '/var/spool/squid'
  $max_obj_size_in_memory = '64 KB'
  $max_obj_size           = '128 MB'
  $min_obj_size           = '0 KB'
  $cache_swap_low         = '90'
  $cache_swap_high        = '95'
  $cache_mem              = '32 MB'
  $cache_access_log       = '/var/log/squid/access.log'
  $custom_config          = template('easysquid/squid.conf.example.erb')

  class {'easysquid':
    custom_config          => $custom_config,
  }
}
