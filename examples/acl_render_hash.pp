# Instance squid class and set acls by hash.
# This case use create_resources to implement
# acls and accesses. Parameters could be loaded
# from a hiera hash.
#
# acl1 and 3 are literal;
# acl2 render an external file;
class acl_render_hash {

  $content       = "google.com\n globo.com\n"
  $acl_min_range = 100

  class {'easysquid':
    acl_min_range => $acl_min_range,
    acls          => {
      'Intranet definition' => {
        acl_name  => 'intranet',
        acl_type  => 'src',
        acl_args  => '10.0.0.0/24',
        acl_order => ($acl_min_range + 2),
      },
      'Domains whitelist'   => {
        acl_name  => 'whitelist',
        acl_type  => 'dstdomain',
        acl_args  => '/etc/squid/whitelist.conf',
        ensure    => 'file',
        content   => $content,
        acl_order => ($acl_min_range + 3),
      },
      'Banned site'         => {
        acl_name   => 'bannedsite',
        acl_type   => 'url_regex',
        acl_args   => '^http[s]*://freaksite',
        acl_action => 'deny',
        acl_order  => ($acl_min_range + 1),
      }
    }
  }
}
