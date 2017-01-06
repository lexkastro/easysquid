# Class: easysquid
# ================
#
# Installs and configures squid in an easy way.
#
#
# Parameters
# ----------
#
# See easysquid::params. Every parameter is assigned by its defaults there.
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
# Copyright (C) 2017 Alex De Castro.
#
class easysquid (
  $custom_config          = $easysquid::params::custom_config,
  $package_name           = $easysquid::params::package_name,
  $app_name               = $easysquid::params::app_name,
  $service_name           = $easysquid::params::service_name,
  $config_path            = $easysquid::params::config_path,
  $config_file_name       = $easysquid::params::config_file_name,
  $cache_path             = $easysquid::params::cache_path,
  $cache_mgr              = $easysquid::params::cache_mgr,
  $acls                   = $easysquid::params::acls,
  $http_port              = $easysquid::params::http_port,
  $cache_size_mb          = $easysquid::params::cache_size_mb,
  $cache_l1               = $easysquid::params::cache_l1,
  $cache_l2               = $easysquid::params::cache_l2,
  $coredump_dir           = $easysquid::params::coredump_dir,
  $user                   = $easysquid::params::user,
  $userid                 = $easysquid::params::userid,
  $group                  = $easysquid::params::group,
  $groupid                = $easysquid::params::groupid,
  $tpl_main               = $easysquid::params::tpl_main,
  $tpl_acls               = $easysquid::params::tpl_acls,
  $tpl_httpaccess         = $easysquid::params::tpl_httpaccess,
  $tpl_refpattern         = $easysquid::params::tpl_refpattern,
  $tpl_error_page         = $easysquid::params::tpl_error_page,
  $tpl_mime_page          = $easysquid::params::tpl_mime_page,
  $tpl_cachemgr           = $easysquid::params::tpl_cachemgr,
  $main_min_range         = $easysquid::params::main_min_range,
  $main_max_range         = $easysquid::params::main_max_range,
  $acl_min_range          = $easysquid::params::acl_min_range,
  $acl_max_range          = $easysquid::params::acl_max_range,
  $httpaccess_min_range   = $easysquid::params::httpaccess_min_range,
  $httpaccess_max_range   = $easysquid::params::httpaccess_max_range,
  $max_obj_size_in_memory = $easysquid::params::max_obj_size_in_memory,
  $max_obj_size           = $easysquid::params::max_obj_size,
  $min_obj_size           = $easysquid::params::min_obj_size,
  $cache_swap_low         = $easysquid::params::cache_swap_low,
  $cache_swap_high        = $easysquid::params::cache_swap_high,
  $cache_access_log       = $easysquid::params::cache_access_log,
  $cache_mem              = $easysquid::params::cache_mem,
  $refresh_pattern        = $easysquid::params::refresh_pattern,
) inherits easysquid::params {

  # Limit to compatible systems.
  case $::osfamily {
    'RedHat': {
      if ( $::operatingsystemmajrelease !~ /(6|7)/ ) {
        fail ('Unsuported OS Version') 
      }
    }
    'Debian': {
      if ( $::operatingsystemmajrelease != '7' ){
        fail ('Unsuported OS Version')
      }
    }
    default: { fail ('Unsuported OS') }
  }

  include easysquid::install
  include easysquid::config
  include easysquid::service
}
