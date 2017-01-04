# Define: easysquid::setconfig
# ============================
#
# Generate a custom configuration fragment and put it inside main
# configuration file.
#
# Parameters
# ----------
#
# * `code`
# Code to insert in main file. Basicall
#
# * `order`
# An integer to represent order of configuration along the file.
# Keep it between 50->99, 200->299 or 400->..., because the ranges
# 0->49, 100->199 and 300->399 are reserved for main config, acls
# and http_access, respectively.
#
# Examples
#
#  # Defining some extra configuration:
#  easysquid::setconfig {'Extra config':
#    code  => template('modulename/template.erb'),
#    order => 404,
#  }
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
define easysquid::setconfig (
  $code,
  $order,
){
  require easysquid

  $main_min_range       = $easysquid::main_min_range
  $main_max_range       = $easysquid::main_max_range
  $acl_min_range        = $easysquid::acl_min_range
  $acl_max_range        = $easysquid::acl_max_range
  $httpaccess_min_range = $easysquid::httpaccess_min_range
  $httpaccess_max_range = $easysquid::httpaccess_max_range

  $comment              = $title
  $main_config_file     = "${easysquid::config_path}/${easysquid::config_file_name}"

  # Block config along used ranges
  if($order == $main_min_range) {
    fail ("You cannot allocate \"${title}\" in main_min_range. It's reserved for main block.")
  }

  if((!($order >  $main_min_range)       and !($order <= $main_max_range)) or
    (  ($order >= $acl_min_range)        and  ($order <= $acl_max_range))  or
    (  ($order >= $httpaccess_min_range) and  ($order <= $httpaccess_max_range))) {
      fail ('easysquid::setconfig: The order was defined along blocked range')
  }

  # Define ACL
  concat::fragment {$comment:
    target  => $main_config_file,
    order   => $order,
    content => $code,
  }
}
