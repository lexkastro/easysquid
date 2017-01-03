# == Class: easysquid::fragments
#
# Set configuration fragments for squid service.
#
# === Variables
#
# * `acls`
# An array ao hashes in the format below. See the define
# easysquid::acl to understand parameters.
# Default: undef
#
# * `config_path`
# Path where configuration files are stored, according to tested  osfamilies.
# Default: /etc/${app_name}
#
# * `config_file_name`
# Name of configuration file..
# Default: ${app_name}.conf
#
# * `cache_path`
# Cache file location.
# Default: /var/spool/${app_name}
#
# * `cache_size_mb`
# Cache size in Mbytes.
# Default: 128
#
# * `cache_l1`
# Number of subdirectories in the first level of cache path.
# Default: 16
#
# * `cache_l2`
# Number of subdirectories in the second level of cache path.
# Default: 256
#
# * `cache_mgr`
# Defines a server list to be managed with cachemgr.cgi. 
# Each item can be assigned as hostname or hostname:port.
# Default: If ommited, assumes undef and, in this case,
# the template render only the entry localhost.
#
# * `http_port`
# Port which squid will listen.
# Default: '3128'
#
# * `coredump_dir`
# Where to write core dumps.
# Default: $cache_path
#
# * `tpl_main`
# Template used for main block.
# Default = easysquid/tpl_main.erb
#
# * `tpl_acls`
# Template to mark acl block. The default template configure localhost ACL
# automatically.
# Default = easysquid/tpl_acls.erb.
#
# * `tpl_httpaccess`
# Template used for http_access block. It allows localhost ACL by default.
# Default = easysquid/tpl_httpaccess.erb.
#
# * `tpl_refpattern`
# Template used for refresh pattern block.
# Default = easysquid/tpl_refpattern.erb.
#
# * `custom_config`
# Used only if you want to use a custom template. If it's different from undef,
# will cause easysquid to ignore class fragments and apply only the custom 
# template received as value in the parameter.
# Default = undef.
#
# * `main_max_range`
# The last position for inserting fragements in the main block.
# Default = 99.
#
# * `acl_min_range`
# Intial position for ACL configuration fragments.
# Default = 100.
#
# * `httpaccess_min_range`
# Initial allowed podition to insert http_accesses fragments.
# Default = 300.
#
# * `httpaccess_max_range`
# Final allowed podition to insert http_accesses fragments.
# Default = 399.
# 
# * `ref_pattern_range`
# Position for refresh pattern block
# Default: ($easysquid::httpaccess_max_range + 1)
#
# * `refresh_pattern`
# An array of hashes with the object refresh pattern. It will be iterated inside
# tpl_refpattern.erb.
# Default = [
#  {
#    're_proto' => '^ftp:',
#    'obj_age'  => '1440',
#    'pct_age'  => '20',
#    'max_age'  => '10080',
#    'opt'      => '',},
#  {
#    're_proto' => '^gopher:',
#    'obj_age'  => '1440',
#    'pct_age'  => '0',
#    'max_age'  => '1440',
#    'opt'      => '',},
#  {
#    're_proto' => '-i (/cgi-bin/|\?)',
#    'obj_age'  => '0',
#    'pct_age'  => '0',
#    'max_age'  => '0',
#    'opt'      => '',},
#  {
#    're_proto' => '.',
#    'obj_age'  => '0',
#    'pct_age'  => '20',
#    'max_age'  => '4320',
#    'opt'      => '',
#  },
#]
#
#
# === Examples
#
#  include easysquid::config
#
# === Authors
#
# Alex De Castro <lexkastro@gmail.com>
#
# === Copyright
#
# Copyright 2017 Alex De Castro.
#
class easysquid::fragments {

  $acls                 = $easysquid::acls
  $config_path          = $easysquid::config_path
  $config_file_name     = $easysquid::config_file_name
  $cache_path           = $easysquid::cache_path
  $cache_size_mb        = $easysquid::cache_size_mb
  $cache_l1             = $easysquid::cache_l1
  $cache_l2             = $easysquid::cache_l2
  $cache_mgr            = $easysquid::cache_mgr
  $http_port            = $easysquid::http_port
  $coredump_dir         = $easysquid::coredump_dir
  $tpl_cachemgr         = $easysquid::tpl_cachemgr
  $tpl_main             = $easysquid::tpl_main
  $tpl_acls             = $easysquid::tpl_acls
  $tpl_httpaccess       = $easysquid::tpl_httpaccess
  $tpl_refpattern       = $easysquid::tpl_refpattern
  $custom_config        = $easysquid::custom_config
  $acl_min_range        = $easysquid::acl_min_range
  $main_min_range       = $easysquid::main_min_range
  $httpaccess_min_range = $easysquid::httpaccess_min_range
  $httpaccess_max_range = $easysquid::httpaccess_max_range
  $ref_pattern_range    = ($easysquid::httpaccess_max_range + 1)
  $refresh_pattern      = $easysquid::refresh_pattern

  $main_config = "${config_path}/${config_file_name}"

  # Main parameters
  # Depends on:
  #   $cache_path;
  #   $cache_size_mb;
  #   $cache_l1
  #   $cache_l2
  #   $coredump_dir;
  #   $http_port;
  concat::fragment {'squid-main-configuration-content':
    target  => $main_config,
    order   => $main_min_range,
    content => template($tpl_main),
  }

  # ACL block
  # It already defines localhost acl
  concat::fragment {'acl-block-begin':
    target  => $main_config,
    order   => $acl_min_range,
    content => template($tpl_acls),
  }

  # If you have defined acls hash, it will be loaded here.
  if ($acls) {
    create_resources ('easysquid::acl', $acls)
  }

  # Open access block
  concat::fragment {'access-block-begin':
    target  => $main_config,
    order   => $httpaccess_min_range,
    content => template($tpl_httpaccess),
  }

  # Close access block
  concat::fragment {'access-block-end':
    target  => $main_config,
    order   => $httpaccess_max_range,
    content => "\n# Block all other remaining access\nhttp_access deny all\n",
  }

  # Refresh pattern block
  if ($refresh_pattern) {
    concat::fragment {'refresh-pattern-block':
      target  => $main_config,
      order   => $ref_pattern_range,
      content => template($tpl_refpattern),
    }
  }
}
