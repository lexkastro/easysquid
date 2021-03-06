# lexkastro/easysquid

Easysquid installs and configures squid easilly. In fact, it will allow you to create a proxy server exposing only the most important parameters. If you need more specifc configuration, it's possible to insert extra code fragments to supply them. The main idea is to be simple and flexible.


## Summary

+ [Structure](#structure)
+ [Block Ranges](#block-ranges)
    + [Main Block](#main-block)
    + [ACL Block](#acl-block)
    + [HTTP_Access Block](#http_access-block)
    + [Refresh Pattern Block](#refresh-pattern-block)
+ [Usage](#usage)
    + [Specifying ACL's Manually](#specifying-acls-manually)
    + [Specifying ACLS as a hash](#specifying-acls-as-a-hash)
    + [Input extra configuration](#input-extra-configuration)
    + [Defining all configuration in a custom squid.conf file](#defining-all-configuration-in-a-custom-squidconf-file)
    + [Proxy Authentication](#proxy-authentication)
+ [Parameter documentation](#parameter-documentation)
+ [License](#license)
+ [Limitations](#limitations)
+ [Contact](#contact)
+ [Support](#support)



## Structure

Easysquid has configuration blocks fixed in its structure, which grants some plainness to deployments. Each configuration block has a pair of indexes to bound the first and last line of each one. That's why we use `concat::fragment` to build main configuration file. With this approach, we can limit the borders of fixed blocks and insert extra custom configuration, if necessary, before, between or after those blocks.

Each number represents a position in a configuration fragment with one or more lines. It's important to put ACLs or extra code in the right position to avoid misconfiguration.


### Block ranges

The default values for block range are set as follows.


    0         : Reserved to main class parameters by default;
    1   -> 99 : You can freely use to insert extra configuration in main session;
    100 -> 199: Reserved to ACL definition list;
    200 -> 299: You can freely use to insert extra configuration;
    300 -> 399: Reserved to HTTP_ACCESS rules;
    400       : Refresh pattern list;
    401 -> N  : Put everithing you need;



For example, if you need to insert extra configuration in the main block, use the define `easysquid::setconfig` to put it in the correct position. Remember to insert only the configuration that is not provided by class parameters to avoid conflict between extra configuration and default applied parameters.

```puppet
  easysquid::setconfig {'authentication block':
    code => $extra_configuration,
    order => ($::easysquid::main_min_range + 1),
  }
``` 


If you prefer, it's possible to reassign range parameter values.

```puppet
  class {'easysquid':
    acls                   => $acls_hash,
    main_min_range         => 0,
    main_max_range         => 20,
    acl_min_range          => 40,
    acl_max_range          => 60,
    httpaccess_min_range   => 80,
    httpaccess_max_range   => 100,
  } 
```



### Main Block

The main block keeps the basic parameters. The position zero is reserved to the main ones, idealized as class parameters. In fact, the main class parameters are a set of attributes probably required for any proxy server deployment.

If you need to extend the main block, you can assign custom fragments to complement it by using positions between 1 and 99 on your fragments with the define `easysquid::setconfig`.

app_name
This parameter is assigned by default considering $::osfamily fact. It expands to *squid* or *squid3*, depending of the operational system and it's used to define other strings along configuration. Otherwise, you can explicit assign a value here to solve a requirement of your system.

**http_port**  
Port where squid will bind client requests.  
Default = '3128'.

**cache_path**  
Full path to the file where squid will store cache objects.  
Default = "/var/spool/${app_name}"

**cache_size_mb**  
Size of the object cache in Mbytes.  
Default = 128.

**cache_l1**  
Number of subdirectories in the first level of disk cache.  
Default = 16.

**cache_l2**  
Number of subdirectories below each level one subdirectory.  
Default = 256.

**coredump_dir**  
Directory where squid will leave core dumps.  
Default = $cache_path

**max_obj_size_in_memory**  
Objects greater than this, won't be cached in memory. The format is a number followed by storage unit (KB, MB, GB, etc).  
Default = '64 KB'

**max_obj_size**  
Limits the maximum size of an object in any cache directory. The format is a number followed by storage unit (KB, MB, GB, etc).  
Default = '32 MB'

**min_obj_size**  
Limits the minimum size of an object in any cache directory. The format is a number followed by storage unit (KB, MB, GB, etc).  
Default = '0 KB'

**cache_swap_low**  
Percentage which squid will start to purge old objects from cache.  
Default = '90'

**cache_swap_high**  
In this watermark, old objects will be purged more aggressively, till the proxy reaches below cache\_swap\_low watermark.  
Default = '95'.

**cache_access_log**  
File where accesses will be logged.  
Default = "/var/log/${app\_name}/access\_log".

**cache_mem**  
Maximum size for the memory cache. The format is a number followed by storage unit (KB, MB, GB, etc). Remember this cache is formed by four-kylobytes pages.  
Default = '32 MB'.



### ACL Block

This block is reserved to define ACL list. You can create ACLs by assigning them to the define `easysquid::acl` or symply putting it all as a hash in the parameter `easysquid::acls`, or even both approaches.

ACLs are created, like said before, with the define `easysquid::acl`. This define creates the ACL and also HTTP\_ACCESS clauses at the same time. It uses the same order in both blocks.

The define `easysquid::acl` will block any ACL which order has been defined out of the default/customized fixed ranges.

Each ACL must have the following structure:

**acl_name**  
Name of the acl. Use only alphabetic, followed by alphanumeric and underscores only. For exemplo 'internal\_lan', 'vlan\_001', etc.  
Default = Must be supplied.

**acl_type**  
Type of ACL. Squid has a lot - 'src', 'dst', 'localip', 'dstdomain', 'url\_regex', etc.  
Default = Must be supplied.

**ensure**  
It can be set as 'argument' or 'file'. If you want to put ACL arguments directly in the ACL command, it will be 'argument'; If you want to reference an external include file with a list of arguments, then ensure must be set as 'file'.  
If you specified 'file', you must pass path in the `$acl_args` parameter and the content in `$content`. In this case, the file will be created and managed by puppet.

**content**  
If you assigned ensure as 'file', it will be the file content and the define will raise an error if you don't provide it.  
Default  = undef.

**acl_action**  
Simply 'allow' or 'deny'.  
Default = 'allow'

**acl_order**  
Order that ACL and HTTP\_ACCESS will be rendered in its configuration blocks. For instance, considering acl block ranges from 100 to 199 and http\_access ranges from 300 to 399, if you set order as 103 , http\_access will automatically be assigned as 303.  
You can use relative positioning to `$acl_min_range`. For example, setting acl\_order like `($easysqui::acl_min_range + 3)` takes the same effect above and http\_access order will turn ($easysquid::httpaccess\_min\_range + 3).  
Default = ($easysquid::acl\_min\_range + 1),



### HTTP\_ACCESS Block

In this configuration block the http\_access rules will be rendered. You cannot define http\_access without acl definition. In fact, it will be created at the same time by `easysquid::acl` in the a relative order based on ACL position.  
The last rule will always be `http_access deny all` (automatically).



### Refresh Pattern Block
The refresh\_pattern clause defines regular expressions to map specific request patterns and how long they will be considered fresh in the cashe. All the refersh pattern configuration can be assigned as a single array of hashes in the `easysquid::refresh_pattern` class parameter. Usually, it's not necessary to change defaults, but if you need, you can reassign the hash using the following structure:

```puppet
# The example below is the default value
[
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
    'opt'      => '',
  },
]
```

Where:

**re_proto**  
A regular expression to map request pattern

**obj_age**  
It's the time (in minutes) an object without an explicit expiration time should be considered fresh.

**pct_age**  
It's the percentage of the objects age (time since last modification age) an object without explicit expiry time will be considered fresh.

**max_age**  
This is an upper limit on how long objects without an explicit expiration time will be considered fresh

**opt**  
Optional arguments to supplement refresh patterns. For example, override-expire, override-lastmod, reload-into-ims, ignore-reload, ignore-no-store, etc. See squid documentation.



This will render the block as shown below. Feel free to overwrite if needed.

```shell
  # ################################ #
  #         REFRESH PATTERN          #
  # ################################ #

  refresh_pattern ^ftp:                     1440   20       10080
  refresh_pattern ^gopher:                  1440   0        1440
  refresh_pattern -i (/cgi-bin/|\?)         0      0        0
  refresh_pattern .                         0      20       4320
```



## Usage

Easysquid has two configuration approaches with some variants. Both of them will instance the module. The difference is how to declare ACLs and Access rules.

### Specifying ACLs manually
Just apply easysquid, customize parameters if needed and apply each ACL with `easysquid::acl`

```puppet
  $content = template('my_wrapper_class/my_whitelist.erb')

  class {'easysquid': } ->

  easysquid::acl {'Intranet definition':
    acl_name  => 'intranet',
    acl_type  => 'src',
    acl_args  => '10.0.0.0/24',
    acl_order => ($::easysquid::acl_min_range + 1)
  } -> 

  easysquid::acl {'IP Exclusivo':
    acl_name  => 'ip_exclusivo',
    acl_type  => 'dst',
    acl_args  => '192.168.0.233',
    acl_order => ($::easysquid::acl_min_range + 2)
  } -> 

  easysquid::acl {'Domains whitelist':
    acl_name  => 'whitelist',
    acl_type  => 'dstdomain',
    acl_args  => '/etc/squid/whitelist.conf',
    ensure    => 'file',
    content   => $content,
    acl_order => ($::easysquid::acl_min_range + 3)
  }
```


### Specifying ACLS as a hash

You can instance easysquid and declare a hash with the ACLs. The define `easysquid::acl` will applied for each item of the hash with a `create_resources` function inside `easysquid::fragments`.

```puppet
  $content       = template('my_wrapper_class/my_whitelist.erb')
  $acl_min_range = 100

  $acls => {
    'Intranet definition' => {
      acl_name   => 'intranet',
      acl_type   => 'src',
      acl_args   => '10.0.0.0/24',
      acl_order  => (acl_min_range + 2),
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
    acls = $acls,
  }
```

### Input extra configuration

As said before, if it's necessary to insert some extra configuration between fixed block range, use the define `easysquid::setconfig` after deploying `easysquid`.

```puppet
  easysquid::setconfig {'extra parameters':
    code => $extra_configuration,
    order => ($::easysquid::main_max_range + 1),
  }
```


### Defining all configuration in a custom squid.conf file.

Imagine someone who has a very specific squid.conf and just want to deploy a squid server and manage his own template. He also wants to automate install, service and a dry template. He doesn't want to control parameters in hiera or declare in a wrapper class or profile.

To achieve this task, you would define custom variables inside your own ERB template and deploy easysquid with `$custom_config` parameter pointing to the new rendered template.


```puppet

  # In the sample below, we have defined some properties
  # to be rendered inside our brand new erb template.
  # 
  class profile::cache {

    $http_port              = '8080'
    $cache_path             = '/var/spool/squid'
    $cache_size_mb          = '128'
    $cache_l1               = '16'
    $cache_l2               = '256'
    $coredump_dir           = '/var/spool/squid'
    $max_obj_size_in_memory = '64 KB'
    $max_obj_size           = '128 MB'
    $min_obj_size           = '0 KB'
    $cache_swap_low         = '90'
    $cache_swap_high        = '95'
    $cache_mem              = '32 MB'
    $cache_access_log       = '/var/log/squid/access.log'

    $custom_config          = template('profile/cache/squid.conf.erb')

    class {'easysquid':
      custom_config          => $custom_config,
    }
  }
```

### Proxy Authentication

Proxy authentication is treated as extra configuration. Authentication clauses in squid usually demand more complex and custom configuration. Considering this feature is achieved by plugins in squid library dir and it differs a lot according to the operational system and version, it could raise complexity and parameter number in this module. So, in this first version, we decided to offer an easy way to put extra code in the configuration file and satisfy any kind of authentication plugin. I will include defines to create plain, ldap, ldap+digest and kerberos authentication fragments in the next versions. But, for now, we can use the define `easysquid::setconfig`.

For example, to insert ldap+digest fragment after main parameters, you can create a wrapper class or profile like this:


```puppet
#
# Profile: profiles::squid_cache
# ==============================
#
class profiles::squid_cache {

  # Authentication Block
  # You must define squid_auth plugin according to
  # operational systems and squid version.
  # Usualy, the auth programs are in squid lib dir.
  # This example runs in RedHat (6.5 and 7.0) and
  # Debian (7.5).
  case $osfamily {
    'RedHat': {
      $program =  $operatingsystemrelease ? {
        '6.5'   => '/usr/lib64/squid/squid_ldap_auth',
        '7.0'   => '/usr/lib64/squid/digest_ldap_auth',
        default => undef,
      }
    }

    'Debian': {
      $program =  $operatingsystemrelease ? {
        '7.5'   => '/usr/lib/squid3/digest_ldap_auth',
        default => undef,
      }
    }

    default: { fail ('Unsuported OS') }
  }

  # LDAP user DN
  $ldap_user       = 'uid=radius,ou=Users,ou=Global,dc=com,dc=br'

  # Password
  $ldap_pass       = 'P@ssFrase'

  # LDAP server
  $ldap_server     = 'auth.mycompany.com.br'

  # Auth Clauses
  $authentication  = "auth_param digest program ${program} -v 3 -b \"ou=MYCOMPANY,dc=com,dc=br\" -D \"${ldap_user}\" -w ${ldap_pass} -F \"uid=%s\" -e -A labeledURI  ${ldap_server}
auth_param digest realm Type login and password
auth_param digest children 50 startup=0 idle=1
auth_param digest nonce_max_duration 600 minutes
auth_param digest nonce_strictness off
auth_param digest check_nonce_count off
auth_param digest post_workaround on
"

  # Instance easysquid
  class {'easysquid':} ->

  # Add authentication clauses
  easysquid::setconfig {'authentication block':
    code => $authentication,
    order => ($::easysquid::main_min_range + 1),
  } ->

  
  # Add authentication ACL and http_access
  easysquid::acl{'LDAP-Digest Auth':
    acl_name   => 'ldap-auth',
    acl_type   => 'proxy_auth',
    acl_args   => 'REQUIRED',
    acl_action => 'allow',
    acl_order  => ($easysquid::acl_min_range + 1),
  }
}
```


## Parameter documentation

**custom_config**  
Used only if you want to use a custom template. If it's different from undef, will cause easysquid to ignore class fragments and apply only the custom template received as value in the parameter.  
Default = undef.

**app_name**  
Name of application used to compose other string parameters.  
Default = Depends on the fact $::osfamily.

**package_name**  
Name of the squid package.  
Default = $app_name.

**service_name**  
Name of the squid service.  
Default = $app_name.

**config_path**  
Full path to configuration directory.  
Default = /etc/${app_name}

**config_file_name**  
Name of the main configuration file.  
Default = ${app_name}.conf

**cache_path**  
Full path to the disk cache.  
Default = /var/spool/${app_name}

**cache_mgr**  
Array with the cache manager hosts. Specify a host per item. If you keep it `undef`, will render only `localhost` entry in the file cachemgr.conf.  
Default = undef.

**acls**  
A hash with the ACL list. It's useful if you manage to build ACL Block and HTTP_ACCESS Block from hiera. It's not mandatory and you can keep it undef and declare each ACL with `easysquid::acl` if you prefer. The `acls` hash can be used when you want to lookup ACLs from hiera database.  
Defautl = undef.

**http_port**  
Default HTTP client port.  
Default = 3128
    
**cache_size_mb**  
Size im Mbytes of the disk cache.  
Default = 128.

**cache_l1**  
Number of directories in the first level of disk cache.  
Default = 16.

**cache_l2**  
Number of directories in the second level of disk cache.  
Default = 256

**coredump_dir**  
Directory where squid will put core dump files.  
Default = $cache_path.

**user**  
User owner of squid instalation.  
Default = root.

**group**  
Group owner of squid instalation.  
Default = squid.

**groupid**  
If you changed default group, it's advisable you use same group ID in each cache node.  
Default = undef.

**tpl_main**  
Template used for main block.  
Default = easysquid/tpl\_main.erb

**tpl_acls**  
Template to mark acl block. The default template configures localhost ACL automatically.  
Default = easysquid/tpl\_acls.erb.

**tpl_httpaccess**  
Template used for http\_access block. It allows localhost ACL by default.  
Default = easysquid/tpl\_httpaccess.erb.

**tpl_refpattern**  
Template used in refresh pattern block.  
Default = easysquid/tpl\_refpattern.erb.

**tpl_error_page**  
Template used for CSS error page (errorpage.css).  
Default = puppet:///modules/easysquid/errorpage.css

**tpl_mime_page**
Template for mime page (mime.conf).
Default = puppet:///modules/easysquid/mime.conf

**tpl_cachemgr**  
Template for cache manager file (cachemgr.conf).  
Default = easysquid/tpl\_cachemgr.erb

**main_min_range**  
It's where the first fragment of configuration will be allocated. The first position is reserved for the main class parameters.
Default = 0

**main_max_range**  
The last position for inserting fragments in the main block.  
Default = 99.

**acl_min_range**  
Intial position for ACL configuration fragments.  
Default = 100.

**acl_max_range**  
Final allowed position to insert ACL fragments.  
Default = 199.

**httpaccess_min_range**  
Initial allowed position to insert http\_accesses fragments.  
Default = 300.

**httpaccess_max_range**  
Final allowed position to insert http\_accesses fragments.  
Default = 399.

**max_obj_size_in_memory**  
Objects greater than this, won't be cached in memory. The format is a number followed by storage unit (KB, MB, GB, etc).  
Default = '64 KB'

**max_obj_size**  
Limits the maximum size of an object in any cache directory. The format is a number followed by storage unit (KB, MB, GB, etc).  
Default = '32 MB'.
       
**min_obj_size**  
Limits the minimum size of an object in any cache directory. The format is a number followed by storage unit (KB, MB, GB, etc).  
Default = '0 KB'

**cache_swap_low**  
Percentage which squid will start to purge old objects from cache.  
Default = '90'

**cache_swap_high**  
In this watermark, old objects will be purged more aggressively, till the proxy reaches below cache\_swap\_low watermark.  
Default = '95'.

**cache_access_log**  
File where accesses will be logged.  
Default = "/var/log/${app\_name}/access\_log".

**cache_mem**  
Maximum size for the memory cache. The format is a number followed by storage unit (KB, MB, GB, etc). Remember this cache is formed by four-kylobytes pages.  
Default = '32 MB'.

**refresh_pattern**  
An array of hashes with the object refresh pattern. It will be iterated inside tpl\_refpattern.erb. See "Refresh Pattern Block" item above.  
Default = 
```puppet
[
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
    'opt'      => '',
  },
]
```



## License

MIT License


## Limitations

Easysquid is in a very fresh version and was tested only in RedHat 6, RedHat 7 and Debian 7. We intend to homolog more operating systems. 
We accept contributions.


## Contact

Alex De Castro (lexkastro@gmail.com)


## Support

Please log tickets and issues at our [Projects site](https://github.com/lexkastro/easysquid/issues)
