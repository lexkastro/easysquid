# Class: easysquid::install
# =========================
#
# Install squid package.
#
# Variables
# ---------
#
# [*package_name*]
#   Name of the squid package. The default value depends
#   on facter osfamily. It was tested only in Redhat and Debian.
#
# Examples
# --------
#
#  include easysquid::install
#
# Authors
# -------
#
# Alex De Castro <lexkastro@gmail.com>
#
# Copyright
# ---------
#
# Copyright (C) 2016 Alex De Castro.
#
class easysquid::install {
  $package_name = $easysquid::package_name

  package {$package_name:
    ensure => installed,
  }
}
