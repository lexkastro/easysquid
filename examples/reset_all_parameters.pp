# Test Case: easysquid::test::reset_all_parameters
# Reset all parameters to verify any mismatch.
#
class reset_all_parameters {

  $rf = [
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
      'opt'      => '',},
  ]

  $content                = "google.com\nglobo.com\nyahoo.com\n"
  $main_min_range         = 0
  $main_max_range         = 20
  $acl_min_range          = 40
  $acl_max_range          = 60
  $httpaccess_min_range   = 80
  $httpaccess_max_range   = 100

  $acls = {
    'Intranet definition' => {
      acl_name   => 'intranet',
      acl_type   => 'src',
      acl_args   => '10.0.0.0/24',
      acl_order  => ($acl_min_range + 2),
    },
    'Domains whitelist' => {
      acl_name   => 'whitelist',
      acl_type   => 'dstdomain',
      acl_args   => '/etc/squid/whitelist.conf',
      ensure     => 'file',
      content    => $content,
      acl_order  => ($acl_min_range + 3),
    },
    'Banned site' => {
      acl_name   => 'bannedsite',
      acl_type   => 'url_regex',
      acl_args   => '^http[s]*://freaksite',
      acl_action => 'deny',
      acl_order  => ($acl_min_range + 1),
    }
  }

  class {'easysquid':
    custom_config          => undef,
    package_name           => squid,
    service_name           => squid,
    config_path            => '/etc/squid',
    config_file_name       => 'squid.conf',
    cache_path             => '/var/spool/squid',
    cache_mgr              => ['localhost','10.0.2.15'],
    acls                   => $acls,
    http_port              => '8080',
    cache_size_mb          => '50',
    cache_l1               => '16',
    cache_l2               => '64',
    coredump_dir           => '/var/spool/squid',
    user                   => 'root',
    group                  => 'proxy',
    tpl_main               => 'easysquid/tpl_main.erb',
    tpl_acls               => 'easysquid/tpl_acls.erb',
    tpl_httpaccess         => 'easysquid/tpl_httpaccess.erb',
    tpl_refpattern         => 'easysquid/tpl_refpattern.erb',
    tpl_cachemgr           => 'easysquid/tpl_cachemgr.erb',
    tpl_error_page         => 'puppet:///modules/easysquid/errorpage.css',
    tpl_mime_page          => 'puppet:///modules/easysquid/mime.conf',
    main_min_range         => $main_min_range,
    main_max_range         => $main_max_range,
    acl_min_range          => $acl_min_range,
    acl_max_range          => $acl_max_range,
    httpaccess_min_range   => $httpaccess_min_range,
    httpaccess_max_range   => $httpaccess_max_range,
    max_obj_size_in_memory => '32 KB',
    max_obj_size           => '16 MB',
    min_obj_size           => '0',
    cache_swap_low         => '95',
    cache_swap_high        => '98',
    cache_access_log       => '/var/log/squid',
    cache_mem              => '16 MB',
    refresh_pattern        => $rf,
  }
}
