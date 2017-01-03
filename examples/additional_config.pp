# Change position for some custom fragments of
# configuration. The $authentication variable
# could be loaded from a custom ERB template.
#
# In this case, we have inserted auth parameters
# along main configuration block.
class additional_config {

  $content                = "google.com\nglobo.com\nyahoo.com\n"
  $main_min_range         = 0
  $main_max_range         = 20
  $acl_min_range          = 40
  $acl_max_range          = 60
  $httpaccess_min_range   = 80
  $httpaccess_max_range   = 100

  # We will insert an authentication block to test the define setconfig.
  $ldap_auth              = '/usr/lib64/squid/squid_ldap_auth'
  $ldap_user              = 'uid=radius,ou=Users,ou=Global,dc=gov,dc=br'
  $ldap_pass              = 'P@ssFrase'
  $ldap_server            = 'auth.mycompany.com.br'
  $authentication         = "auth_param digest program ${ldap_auth} -v 3 -b \"ou=MYCOMPANY,dc=com,dc=br\" -D \"${ldap_user}\" -w ${ldap_pass} -F \"uid=%s\" -e -A labeledURI  ${ldap_server}
auth_param digest realm Type login and password
auth_param digest children 50 startup=0 idle=1
auth_param digest nonce_max_duration 600 minutes
auth_param digest nonce_strictness off
auth_param digest check_nonce_count off
auth_param digest post_workaround on
" 

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
    'LDAP-Digest Auth' => {
      acl_name   => 'ldapdigestauth',
      acl_type   => 'proxy_auth',
      acl_args   => 'REQUIRED',
      acl_action => 'allow',
      acl_order  => ($acl_min_range + 1),
    }
  }

  class {'easysquid':
    acls                   => $acls,
    main_min_range         => $main_min_range,
    main_max_range         => $main_max_range,
    acl_min_range          => $acl_min_range,
    acl_max_range          => $acl_max_range,
    httpaccess_min_range   => $httpaccess_min_range,
    httpaccess_max_range   => $httpaccess_max_range,
  } -> 

  easysquid::setconfig {'authentication block':
    code => $authentication,
    order => ($::easysquid::main_max_range + 1),
  }
}
