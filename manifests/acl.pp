# Define: easysquid::acl
# ======================
#
# Generate an ACL in squid configuration file.
#
#
# Parameters
# ----------
#
# * `acl_name`
# Name of the ACL
#
# * `acl_type`
# The ACL type. Squid has a lot, so it's better to read squid documentation,
# if you has doubts:
#   src, dst, localip, arp, srcdomain, dstdomain, srcdom_regex, dstdom_regex,
#   src_as, dst_as, peername, time, url_regex, urllogin, urlpath_regex, port,
#   localport, myportname, proto, method, http_status, browser, referer_regex,
#   ident, ident_regex, proxy_auth, proxy_auth_regex, snmp_community, maxconn,
#   max_user_ip, random, req_mime_type, req_header, rep_mime_type, rep_header,
#   external, user_cert, ca_cert, ext_user, hier_code, note, 
#   adaptation_service, ssl_error, server_cert_fingerprint, at_step, 
#   ssl::server_name, ssl::server_name_regex, connections_encrypted, any-of,
#   all-of,
#
# * `acl_args`
# ACL argument list. You can pass literaly in a string or a filename filled
# with a list of rules of a specific ACL type. Above follows acl types and
# args examples.
#
#   acl aclname src ip-address/mask
#   acl aclname src addr1-addr2/mask
#   acl aclname dst [-n] ip-address/mask
#   acl aclname localip ip-address/mask
#   acl aclname arp mac-address (xx:xx:xx:xx:xx:xx notation)
#   acl aclname srcdomain .foo.com
#   acl aclname dstdomain [-n] .foo.com
#   acl aclname srcdom_regex [-i] \.foo\.com
#   acl aclname dstdom_regex [-n] [-i] \.foo\.com
#   acl aclname src_as number
#   acl aclname dst_as number
#   acl aclname peername myPeer
#   acl aclname time [day-abbrevs] [h1:m1-h2:m2]
#   acl aclname url_regex [-i] ^http://
#   acl aclname urllogin [-i] [^a-zA-Z0-9]
#   acl aclname urlpath_regex [-i] \.gif$
#   acl aclname port 80 70 21 0-1024
#   acl aclname localport 3128 
#   acl aclname myportname 3128 
#   acl aclname proto HTTP FTP 
#   acl aclname method GET POST 
#   acl aclname http_status 200 301 500- 400-403 
#   acl aclname browser [-i] regexp
#   acl aclname referer_regex [-i] regexp
#   acl aclname ident username
#   acl aclname ident_regex [-i] pattern
#   acl aclname proxy_auth [-i] username
#   acl aclname proxy_auth_regex [-i] pattern
#   acl aclname snmp_community string
#   acl aclname maxconn number
#   acl aclname max_user_ip [-s] number
#   acl aclname random probability
#   acl aclname req_mime_type [-i] mime-type
#   acl aclname req_header header-name [-i] any\.regex\.here
#   acl aclname rep_mime_type [-i] mime-type
#   acl aclname rep_header header-name [-i] any\.regex\.here
#   acl aclname external class_name [arguments...]
#   acl aclname user_cert attribute values...
#   acl aclname ca_cert attribute values...
#   acl aclname ext_user username
#   acl aclname hier_code codename
#   acl aclname note [-m[=delimiters]] name [value ...]
#   acl aclname adaptation_service service
#   acl aclname ssl_error errorname
#   acl aclname server_cert_fingerprint [-sha1] fingerprint
#   acl aclname at_step step
#   acl aclname ssl::server_name .foo.com
#   acl aclname ssl::server_name_regex [-i] \.foo\.com
#   acl aclname connections_encrypted
#   acl aclname any-of acl1 acl2
#   acl aclname all-of acl1 acl2 ...
#
#  Default: undef
#
# * `ensure`
# file: It will try to create a file with acl_args value. In
# this case, you must give the content to populate file;
#
# argument: It will append acl_args after acl_type, defininig ACL
# literaly in the config file itself;
#
# Default: argument
#
# * `content`
# If you defined ensure as file, put here the file content. This
# parameter will be ignored if ensure is argument.
# Default: undef
#
# * `acl_order`
# It's the position the ACL will assume along ACL block in the config
# file. This feature is based on puppetlabs-concat and need an order
# definition to apply the fragment in the right position.
# We locked ACL fragment indexes between 100 and 200 to avoid
# messing ACLs and other config clauses, but you can change default
# ranges. If you need more than 100 ACL fragments, its better to put
# them in external files.
#
# * `acl_action`
# What to do with ACL - Allow or deny. By default allow, since,
# in config.pp, we will block all after last http_access definition.
#
#
# Variables
# ---------
#
# * `access_order`
# The position http_access clause that is related to acl will be
# placed. By default, will be acl_order plus 200.
#
#
# Examples
# --------
#
# See README.md
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
# Copyright (c) 2017 Alex De Castro.
#
define easysquid::acl (
  $acl_name,
  $acl_type,
  $acl_args,
  $ensure       = 'argument',
  $content      = undef,
  $acl_action   = 'allow',
  $acl_order    = ($easysquid::acl_min_range + 1),
){
  require easysquid

  $comment              = $title
  $config_path          = $easysquid::config_path
  $config_file_name     = $easysquid::config_file_name
  $acl_min_range        = $easysquid::acl_min_range
  $acl_max_range        = $easysquid::acl_max_range
  $httpaccess_min_range = $easysquid::httpaccess_min_range
  $user                 = $easysquid::user
  $group                = $easysquid::group
  $main_config          = "${config_path}/${config_file_name}"

  # httaccess_max_range is reserved for "deny all", closing block.
  $httpaccess_max_range = "${easysquid::httpaccess_max_range} - 1"

  # Define http_access order based on acl order.
  $access_order = ($acl_order - $acl_min_range + $httpaccess_min_range)

  # Do not allow acl order out of range. Those limits are 
  # setted in params.pp
  if ($acl_order < ($acl_min_range + 1) or $acl_order > $acl_max_range) {
    fail ('easysquid::acl: ACL declared out of permited range.')
  }

  # Controls acl name input.
  if ($acl_name !~ /^[a-zA-Z]+[a-zA-Z0-9_]*$/) {
    fail('easysquid::acl: ACL Name must start alpha, followed by alnum and underscores only.')
  }

  # Controls acl type input.
  if ($acl_type !~ /^[a-z]+[a-z_:]*$/) {
    fail('easysquid::acl: ACL Type must be lowercase, alpha, folowed by alpha and underscores only.')
  }

  # Acl action must be allow or deny.
  if ($acl_action !~ /^allow|deny$/) {
    fail('easysquid::acl: ACL Action  must be allow or deny.')
  }
  # If you specifyed ensure as file, you must give us a content.
  if ($ensure == 'file' and !$content) {
    fail ("easysquid::acl: You must specify a content to ${acl_args}")
  }

  # Controls acl args input. It tries to detect if argument is a file path. In
  # that case, If the path is absolute, use it literaly, otherwise append to
  # squid config path.
  if ($ensure == 'file') {
    # File content must not be null
    if (!$content) {
      fail ('easysquid::acl: File content must not be null.')
    }

    # Absolute Path.
    if ($acl_args =~ /^\/[a-zA-Z0-9]+[a-zA-Z0-9_\-\.\/]*$/) {
      $file_name = $acl_args
    }
    # Relative Path.
    elsif ($acl_args =~ /^[a-zA-Z0-9]+[a-zA-Z0-9_\-\.]*$/) {
      $file_name = "${config_path}/${acl_args}"
    }
    else {
      fail('easysquid::acl: When using ensure file, must pass an absolute or relative file name')
    }

    $acl = "acl ${acl_name} ${acl_type} \"${file_name}\"\n"

    # Custom whitelist.
    file {$file_name:
      ensure  => file,
      owner   => $user,
      group   => $group,
      mode    => '0640',
      content => $content,
      require => File[$config_path],
    }
  }
  else {
    $acl = "acl ${acl_name} ${acl_type} ${acl_args}\n"
  }

  # Define ACL.
  concat::fragment {"acl-${acl_name}":
    target  => $main_config,
    order   => $acl_order,
    content => "\n# ACL: ${comment}\n${acl}",
  }

  # Define HTTP Access.
  concat::fragment {"access-${acl_action}-${acl_name}":
    target  => $main_config,
    order   => $access_order,
    content => "\n# ACCESS: ${comment}\nhttp_access ${acl_action} ${acl_name}\n",
  }
}
