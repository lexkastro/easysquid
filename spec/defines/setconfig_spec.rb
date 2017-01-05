# spec/classes/setconfig_spec.rb

require 'spec_helper'

describe 'easysquid::setconfig' do

  let(:facts) { {:osfamily => 'RedHat'} }

  # Test configuration arrangement in a valid position
  context 'With correct order' do

    let(:title) {'Authentication Block'}
    let(:params) {
      {
        :order  => 3,
        :code   => "auth_param digest program /usr/lib64/squid/squid_ldap_auth -v 3 -b \"ou=MYCOMPANY,dc=com,dc=br\" -D \"uid=radius,ou=Users,ou=Global,dc=gov,dc=br\" -w password -F \"uid=%s\" -e -A labeledURI  auth.mycompany.com
auth_param digest realm Type login and password
auth_param digest children 50 startup=0 idle=1
auth_param digest nonce_max_duration 600 minutes
auth_param digest nonce_strictness off
auth_param digest check_nonce_count off
auth_param digest post_workaround on
"
      }
    }

    it {
      should contain_easysquid__setconfig('Authentication Block')
      should contain_concat__fragment('Authentication Block').with({
        :target  => '/etc/squid/squid.conf',
        :order   => 3,
        :content => "auth_param digest program /usr/lib64/squid/squid_ldap_auth -v 3 -b \"ou=MYCOMPANY,dc=com,dc=br\" -D \"uid=radius,ou=Users,ou=Global,dc=gov,dc=br\" -w password -F \"uid=%s\" -e -A labeledURI  auth.mycompany.com
auth_param digest realm Type login and password
auth_param digest children 50 startup=0 idle=1
auth_param digest nonce_max_duration 600 minutes
auth_param digest nonce_strictness off
auth_param digest check_nonce_count off
auth_param digest post_workaround on
",
      })
    }
  end

  # Test raise of error when insert into reserved main position
  context 'With invalid order in reserved main block' do

    let(:title) {'Authentication Block'}
    let(:params) {
      {
        :order   => 0,
        :content => "auth_param digest program /usr/lib64/squid/squid_ldap_auth -v 3 -b \"ou=MYCOMPANY,dc=com,dc=br\" -D \"uid=radius,ou=Users,ou=Global,dc=gov,dc=br\" -w password -F \"uid=%s\" -e -A labeledURI  auth.mycompany.com
auth_param digest realm Type login and password
auth_param digest children 50 startup=0 idle=1
auth_param digest nonce_max_duration 600 minutes
auth_param digest nonce_strictness off
auth_param digest check_nonce_count off
auth_param digest post_workaround on
",
      }
    }

    it { is_expected.to raise_error(Puppet::Error) }
  end

  # Test raise of error when insert into reserved acl range
  context 'With invalid order in reserved ACL block' do

    let(:title) {'Authentication Block'}
    let(:params) {
      {
        :order  => 101,
        :content => "auth_param digest program /usr/lib64/squid/squid_ldap_auth -v 3 -b \"ou=MYCOMPANY,dc=com,dc=br\" -D \"uid=radius,ou=Users,ou=Global,dc=gov,dc=br\" -w password -F \"uid=%s\" -e -A labeledURI  auth.mycompany.com
auth_param digest realm Type login and password
auth_param digest children 50 startup=0 idle=1
auth_param digest nonce_max_duration 600 minutes
auth_param digest nonce_strictness off
auth_param digest check_nonce_count off
auth_param digest post_workaround on
",
      }
    }

    it { is_expected.to raise_error(Puppet::Error) }
  end

end
