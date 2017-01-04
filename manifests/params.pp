# Class: easysquid::params
# ========================
#
# Full description of class easysquid here.
#
# Variables
# ---------
#
# * `app_name`
# This parameter is assigned by default considering $::osfamily fact. It 
# expands to *squid* or *squid3*, depending of the operational system and 
# it's used to define other strings along configuration. Otherwise, you 
# can explicit assign a value here to solve a requirement of your system.
#
# * `custom_config`
# Can be used if you want to load a custom template for 
# squid configuration file (squid.conf).
# Default: undef
#
# * `package_name`
# Name of the squid package.
# Default = $app_name.
#
# * `service_name`
# Name of the squid service.
# Default = $app_name.
#
# * `cache_path`
# Cache file location.
# Default: /var/spool/${app_name}
#
# * `config_path`
# Path where configuration files are stored, according to tested  osfamilies.
# Default: /etc/${package_name}
#
# * `log_path`
# Log directory.
# Default: /var/log/${app_name}
#
# * `config_file_name`
# Configuration file name.
# Default: $app_name
#
# * `user`
# Configuration files' owner.
# Default: 'root'
#
# * `group`
# Configuration files' group.
# Default: 'squid' ou 'squid3', dependendo de $::osfamily
#
# * `groupid`
# Use it to grant a specific group ID in each proxy node.
# Default: undef
#
# * `tpl_error_page`
# Template used for CSS error page (errorpage.css).
# Default = puppet:///modules/easysquid/errorpage.css
#
# * `tpl_mime_page`
# Template for mime page (mime.conf).
# Default = puppet:///modules/easysquid/mime.conf
#
# * `tpl_cachemgr`
# Template for cache manager file (cachemgr.conf).
# Default = easysquid/tpl_cachemgr.erb
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
# * `cache_mgr`
# Defines a server list to be managed with cachemgr.cgi. 
# Each item can be assigned as hostname or hostname:port.
# Default: If ommited, assumes undef and, in this case,
# the template render only the entry localhost.
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
# * `main_min_range`
# The first position for inserting fragements in the main block.
# Default = 0.
#
# * `main_max_range`
# The last position for inserting fragements in the main block.
# Default = 99.
#
# * `acl_min_range`
# Intial position for ACL configuration fragments.
# Default = 100.
#
# * `acl_max_range`
# Last position for ACL configuration fragments.
# Default = 199.
#
# * `httpaccess_min_range`
# Initial allowed podition to insert http_accesses fragments.
# Default = 300.
#
# * `httpaccess_max_range`
# Final allowed podition to insert http_accesses fragments.
# Default: 399.
#
# * `max_obj_size_in_memory`
# Objects greater than this, won't be cached in memory. The format
# is a number followed by storage unit (KB, MB, GB, etc).
# Default: 64 KB.
#
# * `max_obj_size`
# Limits the maximum size of an object in any cache directory. The
# format is a number followed by storage unit (KB, MB, GB, etc).
# Default: 32 MB.
#
# * `min_obj_size`
# Limits the minimum size of an object in any cache directory. The 
# format is a number followed by storage unit (KB, MB, GB, etc).
# Default: 0 KB.
#
# * `cache_swap_low`
# Percentage which squid will start to purge old objects from cache.
# Default: 90.
#
# * `cache_swap_high`
# In this watermark, old objects will be purged more aggressively, 
# till the proxy reaches below cache_swap_low watermark.
# Default: 95.
#
# * `cache_access_log`
# File where accesses will be logged.
# Default: /var/log/${app_name}/access_log.
#
# * `cache_mem`
# Maximum size for the memory cache. The format is a number followed by
# storage unit (KB, MB, GB, etc). Remember this cache is formed by 
# four-kylobytes pages.
# Default: 32 MB.
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
# ]
#
#
# Examples
# --------
#
# include easysquid::params
#
#
# Authors
# -------
#
# Alex De Castro <lexkastro@gmail.com>
#
#
# Copyright
# ---------
#
# Copyright (C) 2017 Alex De Castro.
#
class easysquid::params {


  case $::osfamily  {
    'RedHat': {
      $app_name = 'squid'
      $user     = 'squid'
      $group    = 'squid'
    }
    'Debian': {
      $app_name = 'squid3'
      $user     = 'proxy'
      $group    = 'proxy'
    }
    default : { fail ('Unsupported SO') }
  }

  $custom_config                 = undef
  $package_name                  = $app_name
  $service_name                  = $app_name
  $cache_path                    = "/var/spool/${app_name}"
  $config_path                   = "/etc/${app_name}"
  $log_path                      = "/var/log/${app_name}"
  $config_file_name              = 'squid.conf'
  $cache_mgr                     = undef
  $acls                          = undef
  $http_port                     = '3128'
  $cache_mem                     = '32 MB'
  $cache_size_mb                 = '128'
  $cache_l1                      = '16'
  $cache_l2                      = '256'
  $max_obj_size_in_memory        = '64 KB'
  $max_obj_size                  = '32 MB'
  $min_obj_size                  = '0 KB'
  $cache_swap_low                = '90'
  $cache_swap_high               = '95'
  $cache_access_log              = "${log_path}/access.log"
  $coredump_dir                  = $cache_path
  $groupid                       = undef
  $userid                        = undef
  $tpl_main                      = 'easysquid/tpl_main.erb'
  $tpl_acls                      = 'easysquid/tpl_acls.erb'
  $tpl_httpaccess                = 'easysquid/tpl_httpaccess.erb'
  $tpl_refpattern                = 'easysquid/tpl_refpattern.erb'
  $tpl_cachemgr                  = 'easysquid/tpl_cachemgr.erb'
  $tpl_error_page                = 'puppet:///modules/easysquid/errorpage.css'
  $tpl_mime_page                 = 'puppet:///modules/easysquid/mime.conf'
  $main_min_range                = 0
  $main_max_range                = 99
  $acl_min_range                 = 100
  $acl_max_range                 = 199
  $httpaccess_min_range          = 300
  $httpaccess_max_range          = 399
  $refresh_pattern               = [
    {
      're_proto' => '^ftp:',
      'obj_age'  => '1440',
      'pct_age'  => '20',
      'max_age'  => '10080',
      'opt'      => '',},
    {
      're_proto' => '^gopher:',
      'obj_age'  => '1440',
      'pct_age'  => '0',
      'max_age'  => '1440',
      'opt'      => '',},
    {
      're_proto' => '-i (/cgi-bin/|\?)',
      'obj_age'  => '0',
      'pct_age'  => '0',
      'max_age'  => '0',
      'opt'      => '',},
    {
      're_proto' => '.',
      'obj_age'  => '0',
      'pct_age'  => '20',
      'max_age'  => '4320',
      'opt'      => '',
    },
  ]
}
