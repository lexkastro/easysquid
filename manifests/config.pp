# Class: easysquid::config
# ========================
#
# Set directories for configuration files and, if custom
# configuration is used, set the main concat file.
#
# Variables
# ---------
#
# * `config_path`
# Path where configuration files are stored, according to tested  osfamilies.
# Default: /etc/${package_name}
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
# * `custom_config`
# Can be used if you want to load a custom template for 
# squid configuration file (squid.conf).
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
# Examples
# --------
#
#  include easysquid::config
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
class easysquid::config {

  $config_path          = $easysquid::config_path
  $config_file_name     = $easysquid::config_file_name
  $user                 = $easysquid::user
  $group                = $easysquid::group
  $groupid              = $easysquid::groupid
  $custom_config        = $easysquid::custom_config
  $tpl_cachemgr         = $easysquid::tpl_cachemgr
  $tpl_mime_page        = $easysquid::tpl_mime_page
  $tpl_error_page       = easysquid::tpl_error_page

  $main_config = "${config_path}/${config_file_name}"

  # If you do not use the default group, we'll create it.
  if ($groupid) {
    group {$group:
      ensure  => present,
      gid     => $groupid,
      require => Class['easysquid::install'],
    }
  }
  else {
    group {$group:
      ensure  => present,
      require => Class['easysquid::install'],
    }
  }

  if ($custom_config) {
    # Configuration directory
    # Will be purged. Only managed files
    # will remain.
    file {$config_path:
      ensure  => directory,
      owner   => $user,
      group   => $group,
      purge   => true,
      recurse => true,
      require => Class['easysquid::install'],
    } ->

    # For those who want to mantain whole config
    # file manually, using easysquid only for
    # service, package managing in a single config
    # file passed as a template.
    file {$main_config:
      ensure  => file,
      owner   => $user,
      group   => $group,
      mode    => '0640',
      content => $custom_config,
      require => File[$config_path],
      notify  => Class['easysquid::service'],
    }
  }
  else {
    include easysquid::fragments
    # Configuration directory
    # Will be purged. Only managed files
    # will remain.
    file {$config_path:
      ensure  => directory,
      purge   => true,
      recurse => true,
      require => Class['easysquid::install'],
    } ->

    # Main configuration file.
    # Depends on:
    #   $user;
    #   $group;
    concat { $main_config :
      ensure => present,
      owner  => $user,
      group  => $group,
      mode   => '0640',
      order  => 'numeric',
    }
  }

  # Cache Manager file.
  # Depends on:
  #   $cache_mgr;
  file {"${config_path}/cachemgr.conf":
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0640',
    content => template($tpl_cachemgr),
    require => File[$config_path],
    notify  => Class['easysquid::service'],
  }

  # Error Page Style Sheet.
  file {"${config_path}/errorpage.css":
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0640',
    source  => $tpl_error_page,
    require => File[$config_path],
  }

  # Mime types mapping.
  file {"${config_path}/mime.conf":
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0640',
    source  => $tpl_mime_page,
    require => File[$config_path],
  }
}
