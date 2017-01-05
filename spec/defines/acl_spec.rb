# spec/classes/acl_spec.rb

require 'spec_helper'

describe 'easysquid::acl' do

  let(:facts) { {:osfamily => 'RedHat'} }

  context 'With ensure => argument' do

    let(:title) {'Intranet definition'}

    let(:params) {
      {
        :acl_name  => 'intranet',
        :acl_type  => 'src',
        :acl_args  => '10.0.0.0/24',
        :acl_order => 101,
      }
    }

    it {
      should contain_easysquid__acl('Intranet definition')
      should contain_concat__fragment('acl-intranet').with({
        :target  => '/etc/squid/squid.conf',
        :order   => 101,
        :content => "\n# ACL: Intranet definition\nacl intranet src 10.0.0.0/24\n",
      })

      should contain_concat__fragment('access-allow-intranet').with({
        :target  => '/etc/squid/squid.conf',
        :order   => 301,
        :content => "\n# ACCESS: Intranet definition\nhttp_access allow intranet\n",
      })
    }
  end

  context 'With ensure => file' do

    let(:title) {'Domains whitelist'}

    let(:params) {
      {
        :ensure    => 'file',
        :acl_name  => 'whitelist',
        :acl_type  => 'dstdomain',
        :acl_args  => '/etc/squid/whitelist.conf',
        :acl_order => 102,
        :content   => "globo.com\ngoogle.com\ndataprev.gov.br"
      }
    }

    it {
      should contain_easysquid__acl('Domains whitelist')
      should contain_concat__fragment('acl-whitelist').with({
        :target  => '/etc/squid/squid.conf',
        :order   => 102,
        :content => "\n# ACL: Domains whitelist\nacl whitelist dstdomain \"/etc/squid/whitelist.conf\"\n",
      })

      should contain_concat__fragment('access-allow-whitelist').with({
        :target  => '/etc/squid/squid.conf',
        :order   => 302,
        :content => "\n# ACCESS: Domains whitelist\nhttp_access allow whitelist\n",
      })

      should contain_file('/etc/squid/whitelist.conf').with({
        :ensure  => 'file',
        :owner   => 'squid',
        :group   => 'squid',
        :mode    => '0640',
        :content => "globo.com\ngoogle.com\ndataprev.gov.br"
      })
    }
  end


end
