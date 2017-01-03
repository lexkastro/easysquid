# Instance squid class and set manually acls.
# This case tests easysquid::acl directly.
#
# acl1 is literal;
# acl2 renders an external file;
class acl_render {

  $content = "google.com\n globo.com\n"

  class {'easysquid': }

  easysquid::acl {'Intranet definition':
    acl_name => 'intranet',
    acl_type => 'src',
    acl_args => '10.0.0.0/24',
  }
 
  easysquid::acl {'IP Exclusivo':
    acl_name => 'ip_exclusivo',
    acl_type => 'dst',
    acl_args => '192.168.0.233',
  }

  easysquid::acl {'Domains whitelist':
    acl_name => 'whitelist',
    acl_type => 'dstdomain',
    acl_args => '/etc/squid/whitelist.conf',
    ensure   => 'file', 
    content  => $content,
  }
}
