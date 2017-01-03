# Class: easysquid::service
# =========================
#
# Install squid service.
#
# Variables
# ---------
#
# [*service_name*]
#   The squid  service name. The default value depends
#   on facter osfamily. It was tested only in Redhat and Debian.
#
# Examples
# --------
#
#  include easysquid::service
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
class easysquid::service {
  $service_name = $easysquid::service_name

  service {$service_name:
    ensure  => running,
    enable  => true,
    require => Class['easysquid::config'],
  }
}
